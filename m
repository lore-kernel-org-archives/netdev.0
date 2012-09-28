From: Chris Clayton <chris2553@googlemail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Fri, 28 Sep 2012 15:28:24 +0100
Message-ID: <5065B408.1020604@googlemail.com>
References: <5057455A.7050108@googlemail.com>  <50588371.40103@googlemail.com>  <505885DC.1060006@googlemail.com>  <1347979239.26523.267.camel@edumazet-glaptop>  <5059E40C.4070607@googlemail.com> <505D5A18.2080507@googlemail.com>  <50643DA1.7070306@googlemail.com>  <1348748042.5093.1168.camel@edumazet-glaptop>  <50649567.2010704@googlemail.com>  <1348779826.5093.1750.camel@edumazet-glaptop>  <1348780624.5093.1767.camel@edumazet-glaptop>  <50656C4A.8090302@googlemail.com> <1348831592.5093.2251.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gpiez@web.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49828 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757430Ab2I1O20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 10:28:26 -0400
Received: by bkcjk13 with SMTP id jk13so3471365bkc.19
        for <netdev@vger.kernel.org>; Fri, 28 Sep 2012 07:28:24 -0700 (PDT)
In-Reply-To: <1348831592.5093.2251.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



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

Two traces

Trace 1 - tap0 (192.168.200.254) whilst pinging router (192.168.0.1)from 
KVM guest (192.168.200.1):

15:03:14.953599 52:54:0c:3b:17:38 > Broadcast, ethertype ARP (0x0806), 
length 42: Request who-has 192.168.200.254 tell 192.168.200.1, length 28
15:03:14.953617 9e:c3:0c:c8:65:8d > 52:54:0c:3b:17:38, ethertype ARP 
(0x0806), length 42: Reply 192.168.200.254 is-at 9e:c3:0c:c8:65:8d, 
length 28
15:03:14.953725 52:54:0c:3b:17:38 > 9e:c3:0c:c8:65:8d, ethertype IPv4 
(0x0800), length 74: 192.168.200.1 > 192.168.0.1: ICMP echo request, id 
512, seq 5376, length 40
15:03:20.427278 52:54:0c:3b:17:38 > 9e:c3:0c:c8:65:8d, ethertype IPv4 
(0x0800), length 74: 192.168.200.1 > 192.168.0.1: ICMP echo request, id 
512, seq 5632, length 40
15:03:25.942215 52:54:0c:3b:17:38 > 9e:c3:0c:c8:65:8d, ethertype IPv4 
(0x0800), length 74: 192.168.200.1 > 192.168.0.1: ICMP echo request, id 
512, seq 5888, length 40
15:03:31.455578 52:54:0c:3b:17:38 > 9e:c3:0c:c8:65:8d, ethertype IPv4 
(0x0800), length 74: 192.168.200.1 > 192.168.0.1: ICMP echo request, id 
512, seq 6144, length 40

Trace 2 - eth0 (192.168.0.40) whilst pinging router (192.168.0.1)from 
KVM guest (192.168.200.1):

15:04:06.427863 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 74: 192.168.0.40 > 192.168.0.1: ICMP echo request, id 
512, seq 6400, length 40
15:04:06.432100 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 74: 192.168.0.1 > 192.168.0.40: ICMP echo reply, id 
512, seq 6400, length 40
15:04:11.430877 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype ARP 
(0x0806), length 60: Request who-has 192.168.0.40 tell 192.168.0.1, 
length 46
15:04:11.430898 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype ARP 
(0x0806), length 42: Reply 192.168.0.40 is-at 5c:9a:d8:5c:63:31, length 28
15:04:11.567319 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 74: 192.168.0.40 > 192.168.0.1: ICMP echo request, id 
512, seq 6656, length 40
15:04:11.571534 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 74: 192.168.0.1 > 192.168.0.40: ICMP echo reply, id 
512, seq 6656, length 40
15:04:16.577137 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype ARP 
(0x0806), length 42: Request who-has 192.168.0.1 tell 192.168.0.40, 
length 28
15:04:16.580373 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype ARP 
(0x0806), length 60: Reply 192.168.0.1 is-at 00:1f:33:80:09:44, length 46
15:04:17.083328 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 74: 192.168.0.40 > 192.168.0.1: ICMP echo request, id 
512, seq 6912, length 40
15:04:17.086854 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 74: 192.168.0.1 > 192.168.0.40: ICMP echo reply, id 
512, seq 6912, length 40
15:04:22.585766 5c:9a:d8:5c:63:31 > 00:1f:33:80:09:44, ethertype IPv4 
(0x0800), length 74: 192.168.0.40 > 192.168.0.1: ICMP echo request, id 
512, seq 7168, length 40
15:04:22.589989 00:1f:33:80:09:44 > 5c:9a:d8:5c:63:31, ethertype IPv4 
(0x0800), length 74: 192.168.0.1 > 192.168.0.40: ICMP echo reply, id 
512, seq 7168, length 40
15:04:32.240422 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 446: 192.168.0.112.2704 > 239.255.255.250.1900: UDP, 
length 404
15:04:32.241404 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 455: 192.168.0.112.2704 > 239.255.255.250.1900: UDP, 
length 413
15:04:32.242915 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 494: 192.168.0.112.2704 > 239.255.255.250.1900: UDP, 
length 452
15:04:32.243986 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 490: 192.168.0.112.1434 > 239.255.255.250.1900: UDP, 
length 448
15:04:32.245476 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 486: 192.168.0.112.2901 > 239.255.255.250.1900: UDP, 
length 444
15:04:32.246545 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 486: 192.168.0.112.3828 > 239.255.255.250.1900: UDP, 
length 444
15:04:32.342459 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 446: 192.168.0.112.4445 > 239.255.255.250.1900: UDP, 
length 404
15:04:32.343506 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 455: 192.168.0.112.4445 > 239.255.255.250.1900: UDP, 
length 413
15:04:32.345017 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 494: 192.168.0.112.4445 > 239.255.255.250.1900: UDP, 
length 452
15:04:32.346087 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 490: 192.168.0.112.2735 > 239.255.255.250.1900: UDP, 
length 448
15:04:32.348314 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 486: 192.168.0.112.4940 > 239.255.255.250.1900: UDP, 
length 444
15:04:32.349362 00:19:fb:be:cb:55 > 01:00:5e:7f:ff:fa, ethertype IPv4 
(0x0800), length 486: 192.168.0.112.1029 > 239.255.255.250.1900: UDP, 
length 444

The second trace seems to contain some upnp-related traffic involving my 
satellite TV box. If it would help, I can turn that off when my wife 
isn't watching TV, and run the traces again.

Chris

>
>
>
>
