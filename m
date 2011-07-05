From: Adam Katz <adamkatz0@gmail.com>
Subject: Re: libpcap and tc filters
Date: Tue, 5 Jul 2011 18:16:25 +0300
Message-ID: <CAA0qwj49XzNa-nY82X3d_eZ95seS15qELbJDYCNfRkg03OJosQ@mail.gmail.com>
References: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
	<1309777908.26180.1.camel@mojatatu>
	<CAA0qwj70-qUQ+6NL=2LP05TyMN99MdL1BF8tko+v=DhdyjZjJQ@mail.gmail.com>
	<CAA0qwj7cH8Ah69fBMkXpGkwG77TH_ZqMhKwj-Cc8Vc=F5c9SSw@mail.gmail.com>
	<1309784740.26180.21.camel@mojatatu>
	<CAA0qwj4=bOU3LDsRk591AtBWx2c_6uFwk0M4-AGrnxCPKjbbrw@mail.gmail.com>
	<1309788416.26180.63.camel@mojatatu>
	<CAA0qwj4FUpfdux73WCxFcjX0xp-zNtMwncRRmN7ea1Kr9FX3Kw@mail.gmail.com>
	<1309863403.1765.0.camel@mojatatu>
	<1309870021.1765.41.camel@mojatatu>
	<CAA0qwj5aBWrsqHGddW9FBV2srdGwVMzJKe84BTyRH0Dkr6KgVQ@mail.gmail.com>
	<1309874213.1765.45.camel@mojatatu>
	<CAA0qwj74cvZmkkmA8zBFuXeHdidMco2=de7Li9rDN5Wcp=-G7w@mail.gmail.com>
	<1309876868.1765.53.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:56896 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124Ab1GEPQ0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 11:16:26 -0400
Received: by iyb12 with SMTP id 12so5280640iyb.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 08:16:25 -0700 (PDT)
In-Reply-To: <1309876868.1765.53.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

strange.
I've now tried the exact same configuration and it simply refuses to
work. Maybe your tcpreplay is configured differently...

What distro are you using? What kernel? What version of libpcap?


On Tue, Jul 5, 2011 at 5:41 PM, jamal <hadi@cyberus.ca> wrote:
> On Tue, 2011-07-05 at 17:21 +0300, Adam Katz wrote:
>> Yes. I understand the difference between ETH_P_ALL and ETH_P_IP...
>>
>> Jamal, I've now tested both solutions - changing the rule to "protoc=
ol
>> all" and patching tcpreplay to use ETH_P_IP and both produced the
>> exact same problem as before...
>
> Sorry - dont have much time to chase further, but it works for me.
>
> ---
> hadi@mojatatu10:~$ sudo tc qdisc del dev eth0 root handle 1:
> RTNETLINK answers: Invalid argument
> hadi@mojatatu10:~$ sudo tc qdisc add dev eth0 root handle 1: prio
> priomap 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
> hadi@mojatatu10:~$ sudo tc qdisc add dev eth0 parent 1:1 handle 10:
> pfifo
> hadi@mojatatu10:~$ sudo tc qdisc add dev eth0 parent 1:2 handle 20:
> pfifo
> hadi@mojatatu10:~$ sudo tc qdisc add dev eth0 parent 1:3 handle 30:
> pfifo
> hadi@mojatatu10:~$ sudo tc filter add dev eth0 protocol all parent 1:
> prio 1 u32 match ip dport 22 0xffff flowid 1:1 action ok
> hadi@mojatatu10:~$ sudo tc -s filter ls dev eth0
> filter parent 1: protocol all pref 1 u32
> filter parent 1: protocol all pref 1 u32 fh 800: ht divisor 1
> filter parent 1: protocol all pref 1 u32 fh 800::800 order 2048 key h=
t
> 800 bkt 0 flowid 1:1
> =A0match 00000016/0000ffff at 20
> =A0 =A0 =A0 =A0action order 1: gact action pass
> =A0 =A0 =A0 =A0 random type none pass val 0
> =A0 =A0 =A0 =A0 index 1 ref 1 bind 1 installed 15 sec used 15 sec
> =A0 =A0 =A0 =A0Action statistics:
> =A0 =A0 =A0 =A0Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0=
)
> =A0 =A0 =A0 =A0backlog 0b 0p requeues 0
>
> Note - the "OK" action is just a place holder to count packets.
> Now replay Adam's pcap file:
>
> hadi@mojatatu10:~/Downloads$ sudo tcpreplay
> --intf1=3Deth0 ./port22example.pcap
>
> sending out eth0
> processing file: ./port22example.pcap
> Actual: 50 packets (11594 bytes) sent in 3.66 seconds
> Rated: 3167.8 bps, 0.02 Mbps, 13.66 pps
> Statistics for network device: eth0
> =A0 =A0 =A0 =A0Attempted packets: =A0 =A0 =A0 =A0 50
> =A0 =A0 =A0 =A0Successful packets: =A0 =A0 =A0 =A050
> =A0 =A0 =A0 =A0Failed packets: =A0 =A0 =A0 =A0 =A0 =A00
> =A0 =A0 =A0 =A0Retried packets (ENOBUFS): 0
> =A0 =A0 =A0 =A0Retried packets (EAGAIN): =A00
>
> I dont have any ssh running on this maching. So
> lets check to see if anything was captured by the filter.
>
> -----
> hadi@mojatatu10:~$ sudo tc -s filter ls dev eth0
> filter parent 1: protocol all pref 1 u32
> filter parent 1: protocol all pref 1 u32 fh 800: ht divisor 1
> filter parent 1: protocol all pref 1 u32 fh 800::800 order 2048 key h=
t
> 800 bkt 0 flowid 1:1
> =A0match 00000016/0000ffff at 20
> =A0 =A0 =A0 =A0action order 1: gact action pass
> =A0 =A0 =A0 =A0 random type none pass val 0
> =A0 =A0 =A0 =A0 index 1 ref 1 bind 1 installed 76 sec used 1 sec
> =A0 =A0 =A0 =A0Action statistics:
> =A0 =A0 =A0 =A0Sent 7763 bytes 26 pkt (dropped 0, overlimits 0 requeu=
es 0)
> =A0 =A0 =A0 =A0backlog 0b 0p requeues 0
> ------
>
> cheers,
> jamal
>
>>
>> On Tue, Jul 5, 2011 at 4:56 PM, jamal <hadi@cyberus.ca> wrote:
>> > On Tue, 2011-07-05 at 16:07 +0300, Adam Katz wrote:
>> >
>> >> second, I just took at the libpcap source code and it seems it's =
using
>> >> the same ETH_P_ALL option when binding to an interface. So based =
on
>> >> what you're saying, the same solution of patching libpcap and
>> >> replacing ETH_P_ALL with =A0ETH_P_IP should also make these rules=
 work
>> >> with traffic sent using pure libpcap or any libpcap - based
>> >> application.
>> >
>> > ETH_P_ALL makes sense if you are unsure it is going to be IP. So i=
 would
>> > change/optimize apps only for IP if they are intended to deal with=
 IP
>> > only (same for ARP etc).
>> > In your case, it seems it is tcp only - which runs on top of IP. S=
o
>> > it makes sense to do it for that specific use case etc.
>> >
>> > cheers,
>> > jamal
>> >
>> >
>> >
>
>
>
