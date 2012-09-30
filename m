From: Chris Clayton <chris2553@googlemail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Sun, 30 Sep 2012 16:26:04 +0100
Message-ID: <5068648C.7050005@googlemail.com>
References: <5057455A.7050108@googlemail.com>  <50588371.40103@googlemail.com>  <505885DC.1060006@googlemail.com>  <1347979239.26523.267.camel@edumazet-glaptop>  <5059E40C.4070607@googlemail.com> <505D5A18.2080507@googlemail.com>  <50643DA1.7070306@googlemail.com>  <1348748042.5093.1168.camel@edumazet-glaptop>  <50649567.2010704@googlemail.com>  <1348779826.5093.1750.camel@edumazet-glaptop>  <1348780624.5093.1767.camel@edumazet-glaptop>  <50656C4A.8090302@googlemail.com> <1348831592.5093.2251.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gpiez@web.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48669 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254Ab2I3P0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2012 11:26:05 -0400
Received: by eekb15 with SMTP id b15so2040798eek.19
        for <netdev@vger.kernel.org>; Sun, 30 Sep 2012 08:26:02 -0700 (PDT)
In-Reply-To: <1348831592.5093.2251.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On 09/28/12 12:26, Eric Dumazet wrote:
> On Fri, 2012-09-28 at 10:22 +0100, Chris Clayton wrote:
>
>> No, the WinXP guest is configured with a fixed IP address
>> (192.168.200.1). Subnet mask is 255.255.255.0, and default gateway is
>> 192.168.200.254. DNS is 192.168.0.1.
>>
>
> I have no problem with such a setup, with a linux guest.
>
> Could you send again a tcpdump, but including link-level header ?
> (option -e)
>
> Ideally, you could send two traces, one taken on tap0, and another taken
> on eth0.
>
Below are two more traces that I think may well be more useful than 
those I sent on Friday. They are taken with tcpdump directly (after some 
reading up on that application) rather than tcpdump translations of pcap 
files captured with netsniff-ng. Also, they are taken concurrently, so 
they show the traffic on tap0 and eth0 at the time of an unsuccessful 
attempt to ping the router from the WinXP KVM client. The command was: 
sudo tcpdump -nev -i eth0 -Z chris >eth0.trace

tap0:
16:05:14.909057 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 64: (tos 0x0, ttl 128, id 286, offset 0, flags [none], 
proto UDP (17), length 50)
     192.168.200.1.49391 > 192.168.0.1.domain: 33727+ A? wpad. (22)
16:05:21.909026 52:54:0c:3b:17:39 > Broadcast, ethertype IPv4 (0x0800), 
length 92: (tos 0x0, ttl 128, id 287, offset 0, flags [none], proto UDP 
(17), length 78)
     192.168.200.1.netbios-ns > 192.168.200.255.netbios-ns: NBT UDP 
PACKET(137): QUERY; REQUEST; BROADCAST
16:05:21.909123 62:4e:ff:6b:0d:ce > Broadcast, ethertype IPv4 (0x0800), 
length 264: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto UDP 
(17), length 250)
     192.168.200.254.netbios-dgm > 192.168.200.255.netbios-dgm: NBT UDP 
PACKET(138)
16:05:21.909141 62:4e:ff:6b:0d:ce > Broadcast, ethertype IPv4 (0x0800), 
length 249: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto UDP 
(17), length 235)
     192.168.200.254.netbios-dgm > 192.168.200.255.netbios-dgm: NBT UDP 
PACKET(138)
16:05:22.261009 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 74: (tos 0x0, ttl 128, id 288, offset 0, flags [none], 
proto ICMP (1), length 60)
     192.168.200.1 > 192.168.0.1: ICMP echo request, id 512, seq 3840, 
length 40
16:05:22.704716 52:54:0c:3b:17:39 > Broadcast, ethertype IPv4 (0x0800), 
length 92: (tos 0x0, ttl 128, id 289, offset 0, flags [none], proto UDP 
(17), length 78)
     192.168.200.1.netbios-ns > 192.168.200.255.netbios-ns: NBT UDP 
PACKET(137): QUERY; REQUEST; BROADCAST
16:05:23.457224 52:54:0c:3b:17:39 > Broadcast, ethertype IPv4 (0x0800), 
length 92: (tos 0x0, ttl 128, id 290, offset 0, flags [none], proto UDP 
(17), length 78)
     192.168.200.1.netbios-ns > 192.168.200.255.netbios-ns: NBT UDP 
PACKET(137): QUERY; REQUEST; BROADCAST
16:05:24.208015 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 82: (tos 0x0, ttl 128, id 291, offset 0, flags [none], 
proto UDP (17), length 68)
     192.168.200.1.56551 > 192.168.0.1.domain: 63293+ A? 
download.microsoft.com. (40)
16:05:25.204731 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 82: (tos 0x0, ttl 128, id 292, offset 0, flags [none], 
proto UDP (17), length 68)
     192.168.200.1.56551 > 192.168.0.1.domain: 63293+ A? 
download.microsoft.com. (40)
16:05:26.204743 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 82: (tos 0x0, ttl 128, id 293, offset 0, flags [none], 
proto UDP (17), length 68)
     192.168.200.1.56551 > 192.168.0.1.domain: 63293+ A? 
download.microsoft.com. (40)
16:05:27.580723 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 74: (tos 0x0, ttl 128, id 294, offset 0, flags [none], 
proto ICMP (1), length 60)
     192.168.200.1 > 192.168.0.1: ICMP echo request, id 512, seq 4096, 
length 40
16:05:28.204764 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 82: (tos 0x0, ttl 128, id 295, offset 0, flags [none], 
proto UDP (17), length 68)
     192.168.200.1.56551 > 192.168.0.1.domain: 63293+ A? 
download.microsoft.com. (40)
16:05:32.204731 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 82: (tos 0x0, ttl 128, id 296, offset 0, flags [none], 
proto UDP (17), length 68)
     192.168.200.1.56551 > 192.168.0.1.domain: 63293+ A? 
download.microsoft.com. (40)
16:05:33.080759 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 74: (tos 0x0, ttl 128, id 297, offset 0, flags [none], 
proto ICMP (1), length 60)
     192.168.200.1 > 192.168.0.1: ICMP echo request, id 512, seq 4352, 
length 40
16:05:38.582182 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 74: (tos 0x0, ttl 128, id 298, offset 0, flags [none], 
proto ICMP (1), length 60)
     192.168.200.1 > 192.168.0.1: ICMP echo request, id 512, seq 4608, 
length 40
16:05:39.218737 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 64: (tos 0x0, ttl 128, id 299, offset 0, flags [none], 
proto UDP (17), length 50)
     192.168.200.1.60955 > 192.168.0.1.domain: 26953+ A? wpad. (22)
16:05:40.204735 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 64: (tos 0x0, ttl 128, id 300, offset 0, flags [none], 
proto UDP (17), length 50)
     192.168.200.1.60955 > 192.168.0.1.domain: 26953+ A? wpad. (22)
16:05:41.204721 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 64: (tos 0x0, ttl 128, id 301, offset 0, flags [none], 
proto UDP (17), length 50)
     192.168.200.1.60955 > 192.168.0.1.domain: 26953+ A? wpad. (22)
16:05:43.238517 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 64: (tos 0x0, ttl 128, id 302, offset 0, flags [none], 
proto UDP (17), length 50)
     192.168.200.1.60955 > 192.168.0.1.domain: 26953+ A? wpad. (22)
16:05:47.236721 52:54:0c:3b:17:39 > 62:4e:ff:6b:0d:ce, ethertype IPv4 
(0x0800), length 64: (tos 0x0, ttl 128, id 303, offset 0, flags [none], 
proto UDP (17), length 50)
     192.168.200.1.60955 > 192.168.0.1.domain: 26953+ A? wpad. (22)


eth0:

16:05:22.261037 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 74: (tos 0x0, ttl 127, id 288, offset 0, flags [none], 
proto ICMP (1), length 60)
     192.168.0.40 > 192.168.0.1: ICMP echo request, id 512, seq 3840, 
length 40
16:05:22.264612 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 74: (tos 0x0, ttl 255, id 53593, offset 0, flags 
[none], proto ICMP (1), length 60)
     192.168.0.1 > 192.168.0.40: ICMP echo reply, id 512, seq 3840, 
length 40
16:05:24.208041 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 82: (tos 0x0, ttl 127, id 291, offset 0, flags [none], 
proto UDP (17), length 68)
     192.168.0.40.56551 > 192.168.0.1.domain: 63293+ A? 
download.microsoft.com. (40)
16:05:24.270825 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 426: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], 
proto UDP (17), length 412)
     192.168.0.1.domain > 192.168.0.40.56551: 63293 7/8/0 
download.microsoft.com. CNAME download.microsoft.com.nsatc.net., 
download.microsoft.com.nsatc.net. CNAME main.dl.ms.akadns.net., 
main.dl.ms.akadns.net. CNAME intl.dl.ms.akadns.net., 
intl.dl.ms.akadns.net. CNAME dl.ms.georedirector.akadns.net., 
dl.ms.georedirector.akadns.net. CNAME a767.ms.akamai.net., 
a767.ms.akamai.net. A 90.223.216.161, a767.ms.akamai.net. A 
90.223.216.153 (384)
16:05:25.204745 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 82: (tos 0x0, ttl 127, id 292, offset 0, flags [none], 
proto UDP (17), length 68)
     192.168.0.40.56551 > 192.168.0.1.domain: 63293+ A? 
download.microsoft.com. (40)
16:05:25.266414 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 442: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], 
proto UDP (17), length 428)
     192.168.0.1.domain > 192.168.0.40.56551: 63293 7/8/1 
download.microsoft.com. CNAME download.microsoft.com.nsatc.net., 
download.microsoft.com.nsatc.net. CNAME main.dl.ms.akadns.net., 
main.dl.ms.akadns.net. CNAME intl.dl.ms.akadns.net., 
intl.dl.ms.akadns.net. CNAME dl.ms.georedirector.akadns.net., 
dl.ms.georedirector.akadns.net. CNAME a767.ms.akamai.net., 
a767.ms.akamai.net. A 90.223.216.153, a767.ms.akamai.net. A 
90.223.216.161 (400)
16:05:26.204761 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 82: (tos 0x0, ttl 127, id 293, offset 0, flags [none], 
proto UDP (17), length 68)
     192.168.0.40.56551 > 192.168.0.1.domain: 63293+ A? 
download.microsoft.com. (40)
16:05:26.237788 00:1f:33:80:09:44 > 01:00:5e:00:00:01, ethertype IPv4 
(0x0800), length 60: (tos 0x0, ttl 1, id 0, offset 0, flags [DF], proto 
IGMP (2), length 28)
     192.168.0.1 > 224.0.0.1: igmp query v2
16:05:26.266706 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 458: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], 
proto UDP (17), length 444)
     192.168.0.1.domain > 192.168.0.40.56551: 63293 7/8/2 
download.microsoft.com. CNAME download.microsoft.com.nsatc.net., 
download.microsoft.com.nsatc.net. CNAME main.dl.ms.akadns.net., 
main.dl.ms.akadns.net. CNAME intl.dl.ms.akadns.net., 
intl.dl.ms.akadns.net. CNAME dl.ms.georedirector.akadns.net., 
dl.ms.georedirector.akadns.net. CNAME a767.ms.akamai.net., 
a767.ms.akamai.net. A 90.223.216.161, a767.ms.akamai.net. A 
90.223.216.153 (416)
16:05:27.580742 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 74: (tos 0x0, ttl 127, id 294, offset 0, flags [none], 
proto ICMP (1), length 60)
     192.168.0.40 > 192.168.0.1: ICMP echo request, id 512, seq 4096, 
length 40
16:05:27.585193 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 74: (tos 0x0, ttl 255, id 53594, offset 0, flags 
[none], proto ICMP (1), length 60)
     192.168.0.1 > 192.168.0.40: ICMP echo reply, id 512, seq 4096, 
length 40
16:05:28.204783 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 82: (tos 0x0, ttl 127, id 295, offset 0, flags [none], 
proto UDP (17), length 68)
     192.168.0.40.56551 > 192.168.0.1.domain: 63293+ A? 
download.microsoft.com. (40)
16:05:28.267047 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 442: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], 
proto UDP (17), length 428)
     192.168.0.1.domain > 192.168.0.40.56551: 63293 7/8/1 
download.microsoft.com. CNAME download.microsoft.com.nsatc.net., 
download.microsoft.com.nsatc.net. CNAME main.dl.ms.akadns.net., 
main.dl.ms.akadns.net. CNAME intl.dl.ms.akadns.net., 
intl.dl.ms.akadns.net. CNAME dl.ms.georedirector.akadns.net., 
dl.ms.georedirector.akadns.net. CNAME a767.ms.akamai.net., 
a767.ms.akamai.net. A 90.223.216.161, a767.ms.akamai.net. A 
90.223.216.153 (400)
16:05:29.267032 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype ARP 
(0x0806), length 60: Ethernet (len 6), IPv4 (len 4), Request who-has 
192.168.0.40 tell 192.168.0.1, length 46
16:05:29.267049 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype ARP 
(0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Reply 192.168.0.40 
is-at 5c:9a:d8:5c:63:31, length 28
16:05:32.204753 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 82: (tos 0x0, ttl 127, id 296, offset 0, flags [none], 
proto UDP (17), length 68)
     192.168.0.40.56551 > 192.168.0.1.domain: 63293+ A? 
download.microsoft.com. (40)
16:05:32.267308 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 458: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], 
proto UDP (17), length 444)
     192.168.0.1.domain > 192.168.0.40.56551: 63293 7/8/2 
download.microsoft.com. CNAME download.microsoft.com.nsatc.net., 
download.microsoft.com.nsatc.net. CNAME main.dl.ms.akadns.net., 
main.dl.ms.akadns.net. CNAME intl.dl.ms.akadns.net., 
intl.dl.ms.akadns.net. CNAME dl.ms.georedirector.akadns.net., 
dl.ms.georedirector.akadns.net. CNAME a767.ms.akamai.net., 
a767.ms.akamai.net. A 90.223.216.161, a767.ms.akamai.net. A 
90.223.216.153 (416)
16:05:33.080772 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 74: (tos 0x0, ttl 127, id 297, offset 0, flags [none], 
proto ICMP (1), length 60)
     192.168.0.40 > 192.168.0.1: ICMP echo request, id 512, seq 4352, 
length 40
16:05:33.084435 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 74: (tos 0x0, ttl 255, id 53595, offset 0, flags 
[none], proto ICMP (1), length 60)
     192.168.0.1 > 192.168.0.40: ICMP echo reply, id 512, seq 4352, 
length 40
16:05:35.277471 00:1f:33:80:09:44 > 01:00:5e:00:00:02, ethertype IPv4 
(0x0800), length 60: (tos 0x0, ttl 1, id 0, offset 0, flags [DF], proto 
IGMP (2), length 32, options (RA))
     192.168.0.1 > 224.0.0.2: igmp v2 report 224.0.0.2
16:05:38.582202 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 74: (tos 0x0, ttl 127, id 298, offset 0, flags [none], 
proto ICMP (1), length 60)
     192.168.0.40 > 192.168.0.1: ICMP echo request, id 512, seq 4608, 
length 40
16:05:38.587143 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 74: (tos 0x0, ttl 255, id 53596, offset 0, flags 
[none], proto ICMP (1), length 60)
     192.168.0.1 > 192.168.0.40: ICMP echo reply, id 512, seq 4608, 
length 40
16:05:39.218763 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 64: (tos 0x0, ttl 127, id 299, offset 0, flags [none], 
proto UDP (17), length 50)
     192.168.0.40.60955 > 192.168.0.1.domain: 26953+ A? wpad. (22)
16:05:39.280065 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 139: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], 
proto UDP (17), length 125)
     192.168.0.1.domain > 192.168.0.40.60955: 26953 NXDomain 0/1/0 (97)
16:05:40.204754 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 64: (tos 0x0, ttl 127, id 300, offset 0, flags [none], 
proto UDP (17), length 50)
     192.168.0.40.60955 > 192.168.0.1.domain: 26953+ A? wpad. (22)
16:05:40.266317 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 139: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], 
proto UDP (17), length 125)
     192.168.0.1.domain > 192.168.0.40.60955: 26953 NXDomain 0/1/0 (97)
16:05:41.204738 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 64: (tos 0x0, ttl 127, id 301, offset 0, flags [none], 
proto UDP (17), length 50)
     192.168.0.40.60955 > 192.168.0.1.domain: 26953+ A? wpad. (22)
16:05:41.266343 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 139: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], 
proto UDP (17), length 125)
     192.168.0.1.domain > 192.168.0.40.60955: 26953 NXDomain 0/1/0 (97)
16:05:43.238538 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 64: (tos 0x0, ttl 127, id 302, offset 0, flags [none], 
proto UDP (17), length 50)
     192.168.0.40.60955 > 192.168.0.1.domain: 26953+ A? wpad. (22)
16:05:43.301692 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 139: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], 
proto UDP (17), length 125)
     192.168.0.1.domain > 192.168.0.40.60955: 26953 NXDomain 0/1/0 (97)
16:05:44.230290 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype ARP 
(0x0806), length 42: Ethernet (len 6), IPv4 (len 4), Request who-has 
192.168.0.1 tell 192.168.0.40, length 28
16:05:44.233532 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype ARP 
(0x0806), length 60: Ethernet (len 6), IPv4 (len 4), Reply 192.168.0.1 
is-at 00:1f:33:80:09:44, length 46
16:05:47.236740 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 64: (tos 0x0, ttl 127, id 303, offset 0, flags [none], 
proto UDP (17), length 50)
     192.168.0.40.60955 > 192.168.0.1.domain: 26953+ A? wpad. (22)
16:05:47.296388 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 139: (tos 0x0, ttl 64, id 0, offset 0, flags [DF], 
proto UDP (17), length 125)
     192.168.0.1.domain > 192.168.0.40.60955: 26953 NXDomain 0/1/0 (97)
16:05:48.530940 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 446: (tos 0x0, ttl 4, id 0, offset 0, flags [DF], proto 
UDP (17), length 432)
     192.168.0.112.3829 > 239.255.255.250.1900: UDP, length 404
16:05:48.531962 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 455: (tos 0x0, ttl 4, id 0, offset 0, flags [DF], proto 
UDP (17), length 441)
     192.168.0.112.3829 > 239.255.255.250.1900: UDP, length 413
16:05:48.533472 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 494: (tos 0x0, ttl 4, id 0, offset 0, flags [DF], proto 
UDP (17), length 480)
     192.168.0.112.3829 > 239.255.255.250.1900: UDP, length 452
16:05:48.534564 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 490: (tos 0x0, ttl 4, id 0, offset 0, flags [DF], proto 
UDP (17), length 476)
     192.168.0.112.2600 > 239.255.255.250.1900: UDP, length 448
16:05:48.536749 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 486: (tos 0x0, ttl 4, id 0, offset 0, flags [DF], proto 
UDP (17), length 472)
     192.168.0.112.2411 > 239.255.255.250.1900: UDP, length 444
16:05:48.537798 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 486: (tos 0x0, ttl 4, id 0, offset 0, flags [DF], proto 
UDP (17), length 472)
     192.168.0.112.1205 > 239.255.255.250.1900: UDP, length 444
16:05:48.633492 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 446: (tos 0x0, ttl 4, id 0, offset 0, flags [DF], proto 
UDP (17), length 432)
     192.168.0.112.1378 > 239.255.255.250.1900: UDP, length 404
16:05:48.634558 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 455: (tos 0x0, ttl 4, id 0, offset 0, flags [DF], proto 
UDP (17), length 441)
     192.168.0.112.1378 > 239.255.255.250.1900: UDP, length 413
16:05:48.636069 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 494: (tos 0x0, ttl 4, id 0, offset 0, flags [DF], proto 
UDP (17), length 480)
     192.168.0.112.1378 > 239.255.255.250.1900: UDP, length 452
16:05:48.637119 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 490: (tos 0x0, ttl 4, id 0, offset 0, flags [DF], proto 
UDP (17), length 476)
     192.168.0.112.3487 > 239.255.255.250.1900: UDP, length 448
16:05:48.638631 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 486: (tos 0x0, ttl 4, id 0, offset 0, flags [DF], proto 
UDP (17), length 472)
     192.168.0.112.4415 > 239.255.255.250.1900: UDP, length 444
16:05:48.639702 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 486: (tos 0x0, ttl 4, id 0, offset 0, flags [DF], proto 
UDP (17), length 472)
     192.168.0.112.2700 > 239.255.255.250.1900: UDP, length 444

>
>
>
>
