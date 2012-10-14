From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Sun, 14 Oct 2012 22:45:46 +0200
Message-ID: <1350247546.21172.17167.camel@edumazet-glaptop>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	 <1350242941.21172.17023.camel@edumazet-glaptop>
	 <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
	 <1350244485.21172.17077.camel@edumazet-glaptop>
	 <CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com>
	 <1350246314.21172.17139.camel@edumazet-glaptop>
	 <1350246414.21172.17144.camel@edumazet-glaptop>
	 <1350246481.21172.17147.camel@edumazet-glaptop>
	 <CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:53046 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824Ab2JNUpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2012 16:45:51 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1004676eaa.19
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2012 13:45:50 -0700 (PDT)
In-Reply-To: <CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-14 at 22:39 +0200, Jan Hinnerk Stosch wrote:
> 2012/10/14 Eric Dumazet <eric.dumazet@gmail.com>:
> > On Sun, 2012-10-14 at 22:27 +0200, Eric Dumazet wrote:
> >
> >> Also post :
> >>
> >
> > # grep Udp6 /proc/net/snmp6
> >
> > Before and after your "ntpq -p" try
> >
> >
> 
> Sorry, my fault. I executed the command as user not root:
> lsof: WARNING: can't stat() fuse.gvfs-fuse-daemon file system
> /run/user/1000/gvfs
>       Output information may be incomplete.
> COMMAND PID USER   FD      TYPE             DEVICE SIZE/OFF   NODE NAME
> ntpd    368  ntp  cwd       DIR                8,2     4096      2 /
> ntpd    368  ntp  rtd       DIR                8,2     4096      2 /
> ntpd    368  ntp  txt       REG                8,2   582944 418889 /usr/bin/ntpd
> ntpd    368  ntp  mem       REG                8,2    84832 396501
> /usr/lib/libresolv-2.16.so
> ntpd    368  ntp  mem       REG                8,2    22936 396440
> /usr/lib/libnss_dns-2.16.so
> ntpd    368  ntp  mem       REG                8,2    52136 396470
> /usr/lib/libnss_files-2.16.so
> ntpd    368  ntp  mem       REG                8,2    18760 400111
> /usr/lib/libattr.so.1.1.0
> ntpd    368  ntp  mem       REG                8,2   137998 396481
> /usr/lib/libpthread-2.16.so
> ntpd    368  ntp  mem       REG                8,2    88656 399537
> /usr/lib/libz.so.1.2.7
> ntpd    368  ntp  mem       REG                8,2    14648 396487
> /usr/lib/libdl-2.16.so
> ntpd    368  ntp  mem       REG                8,2  2009849 396474
> /usr/lib/libc-2.16.so
> ntpd    368  ntp  mem       REG                8,2    16776 400227
> /usr/lib/libcap.so.2.22
> ntpd    368  ntp  mem       REG                8,2    31760 396469
> /usr/lib/librt-2.16.so
> ntpd    368  ntp  mem       REG                8,2  2392233 405328
> /usr/lib/libcrypto.so.1.0.0
> ntpd    368  ntp  mem       REG                8,2  1022344 396456
> /usr/lib/libm-2.16.so
> ntpd    368  ntp  mem       REG                8,2   165344 396512
> /usr/lib/ld-2.16.so
> ntpd    368  ntp    0u      CHR                1,3      0t0   1028 /dev/null
> ntpd    368  ntp    1u      CHR                1,3      0t0   1028 /dev/null
> ntpd    368  ntp    2u      CHR                1,3      0t0   1028 /dev/null
> ntpd    368  ntp    3u     unix 0xffff880214dfbb80      0t0  11432 socket
> ntpd    368  ntp    5w      REG                8,2        0 664219
> /var/log/ntp.log
> ntpd    368  ntp   16u     IPv4              10453      0t0    UDP *:ntp
> ntpd    368  ntp   17u     IPv6              10454      0t0    UDP *:ntp
> ntpd    368  ntp   18u     IPv4              10460      0t0    UDP
> localhost.localdomain:ntp
> ntpd    368  ntp   19u     IPv4              10461      0t0    UDP
> hinniepc.fritz.box:ntp
> ntpd    368  ntp   20u     IPv6               8775      0t0    UDP
> [fe80::922b:34ff:fe33:c292]:ntp
> ntpd    368  ntp   21u  netlink                         0t0  10463 ROUTE
> 
> and here is "grep Udp6 /proc/net/snmp6" before:
> Udp6InDatagrams                 	19
> Udp6NoPorts                     	0
> Udp6InErrors                    	0
> Udp6OutDatagrams                	19
> Udp6RcvbufErrors                	0
> Udp6SndbufErrors                	0
> 
> and after running "ntpq -p":
> Udp6InDatagrams                 	21
> Udp6NoPorts                     	0
> Udp6InErrors                    	0
> Udp6OutDatagrams                	21
> Udp6RcvbufErrors                	0
> Udp6SndbufErrors                	0

OK so IPv6 UDP frames are delivered to ntpd

could you strace it while doing one "ntpq -p"

strace -p 368
