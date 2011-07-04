From: Adam Katz <adamkatz0@gmail.com>
Subject: Re: libpcap and tc filters
Date: Mon, 4 Jul 2011 16:24:11 +0300
Message-ID: <CAA0qwj4=bOU3LDsRk591AtBWx2c_6uFwk0M4-AGrnxCPKjbbrw@mail.gmail.com>
References: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
	<1309777908.26180.1.camel@mojatatu>
	<CAA0qwj70-qUQ+6NL=2LP05TyMN99MdL1BF8tko+v=DhdyjZjJQ@mail.gmail.com>
	<CAA0qwj7cH8Ah69fBMkXpGkwG77TH_ZqMhKwj-Cc8Vc=F5c9SSw@mail.gmail.com>
	<1309784740.26180.21.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57283 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757402Ab1GDNYM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 09:24:12 -0400
Received: by iwn6 with SMTP id 6so4438637iwn.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 06:24:11 -0700 (PDT)
In-Reply-To: <1309784740.26180.21.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ok, I checked now and the packets sent by tcpreplay are identical to
the ones captured originally by wireshark.

I'm using the stock ubuntu 10.04 kernel that wasn't compiled with
CONFIG_CLS_U32_PERF so sudo tc -s filter ls dev eth1 shows nothing
useful (and i'm not sure that recompiling the entire kernel is worth
it to tell me what I already know - that these packets missed the
filters... but i'm willing to do it if you think that'll help).
Anyway, I suspect the problem to be something else - I suspect that
the packets sent using tcpreplay simply skip the filters in the kernel
and are being injected somewhere afterwards. But this theory is
problematic since I find it strange that the packets do end up in the
default queue after all - hence they ARE seen by tc and they don't
skip tc entirely.

On Mon, Jul 4, 2011 at 4:05 PM, jamal <hadi@cyberus.ca> wrote:
> On Mon, 2011-07-04 at 15:37 +0300, Adam Katz wrote:
>> here's a more concrete example:
>>
>> An example configuration:
>>
>> =A0 =A0 =A0 sudo tc qdisc add dev eth1 root handle 1: prio priomap 2=
 2 2 2 2 2 2
>> 2 2 2 2 2 2 2 2 2
>> =A0 =A0 =A0 sudo tc qdisc add dev eth1 parent 1:1 handle 10: pfifo
>> =A0 =A0 =A0 sudo tc qdisc add dev eth1 parent 1:2 handle 20: pfifo
>> =A0 =A0 =A0 sudo tc qdisc add dev eth1 parent 1:3 handle 30: pfifo
>> =A0 =A0 =A0 sudo tc filter add dev eth1 protocol ip parent 1: prio 1=
 u32 match ip
>> dport 22 0xffff flowid 1:1
>> =A0 =A0 =A0 sudo tc filter add dev eth1 protocol ip parent 1: prio 1=
 u32 match ip
>> sport 22 0xffff flowid 1:1
>> =A0 =A0 =A0 sudo tc filter add dev eth1 protocol ip parent 1: prio 2=
 u32 match ip
>> dport 80 0xffff flowid 1:2
>> =A0 =A0 =A0 sudo tc filter add dev eth1 protocol ip parent 1: prio 2=
 u32 match ip
>> sport 80 0xffff flowid 1:2
>
>
> looks fine.
>
>> I then used scp to copy a small file between computers while capturi=
ng
>> with wireshark:
>>
>> http://dl.dropbox.com/u/3237005/port22example.pcap
>>
>> and later I replayed the same capture using tcpreplay.
>> When using scp, the packets once again ended up where they should be
>> (1:1 in this configuration). With tcpreplay they ended up in the
>> default 1:3
>
> Where is the capture from tcpreplay? What i was asking is you validat=
e
> that the capture before and what is sent out by tcprelay look the sam=
e.
> Can you please do that?
> It is possible because your filters are not matched they end up on yo=
ur
> default queue based on tos value.
>
> If you have your kernel compiled with CONFIG_CLS_U32_PERF you should
> see when the filters get hit as well
> (do something like sudo tc -s filter ls dev eth1)
>
>
> cheers,
> jamal
>
>
>
>
