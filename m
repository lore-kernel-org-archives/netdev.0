From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276
 problem
Date: Fri, 14 Mar 2014 10:24:42 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1403141020490.5976@gmail.com>
References: <1383555049-24834-1-git-send-email-bjorn@mork.no> <20140313202557.GV3200@reaktio.net> <1394746907.15946.8.camel@dcbw.local> <20140313220812.GW3200@reaktio.net> <20140314075548.GX3200@reaktio.net> <87wqfxnppc.fsf@nemi.mork.no> <20140314084159.GA3200@reaktio.net>
 <87siqlnol8.fsf@nemi.mork.no> <20140314090525.GB3200@reaktio.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-683441087-1015124440-1394789083=:5976"
Cc: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>
To: =?ISO-8859-15?Q?Pasi_K=E4rkk=E4inen?= <pasik@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:44521 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755543AbaCNJYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 05:24:12 -0400
In-Reply-To: <20140314090525.GB3200@reaktio.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---683441087-1015124440-1394789083=:5976
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

I am sorry: no ideas on what to do next. Still, one idea would be to try 
reverting these patches and see if it works with the original cdc_ncm driver, 
and see what happens.
Other than this, I do not have this device at hand, so can't see what happens. 
>From the version number, I expect the firmware being HiSilicon (not Qualcomm).
Try also using dhcpcd if you can / want / like :) .
Thank you.


On Fri, 14 Mar 2014, Pasi Kärkkäinen wrote:

==Date: Fri, 14 Mar 2014 10:05:25
==From: Pasi Kärkkäinen <pasik@iki.fi>
==To: Bjørn Mork <bjorn@mork.no>
==Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
==    linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
==    Oliver Neukum <oliver@neukum.org>
==Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276 problem
==
==On Fri, Mar 14, 2014 at 09:58:43AM +0100, Bjørn Mork wrote:
==> Pasi Kärkkäinen <pasik@iki.fi> writes:
==> 
==> > ^NDISSTAT:1,,,"IPV4"
==> > ^RSSI: 21
==> >
==> > <I send: AT^DHCP?>
==> > ^DHCP: CCDB080A,F8FFFFFF,C9DB080A,C9DB080A,E67B59C0,E77B59C0,85600,85600
==> 
==> 
==> The hex numbers are IPv4 addresses in little endian. The decimal numbers
==> at the end are speed down/up IIRC.
==> 
==> Printed in a more readable form, this is:
==> 
==>  10.8.219.204,255.255.255.248,10.8.219.201,10.8.219.201,192.89.123.230,192.89.123.231,85600,85600
==> 
==> I believe this is to be interpreted as
==> 
==>  yourip, netmask, gw, gw?, dns1, dns2
==> 
==> 
==> Do stuff work if you manually configure the interface with the
==> 10.8.219.204 address and set the default route to 10.8.219.201?
==> 
==
==Unfortunately no :( 
==
==# ifconfig wwp0s26u1u5i1
==wwp0s26u1u5i1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
==        inet 10.8.219.204  netmask 255.255.255.248  broadcast 10.8.219.207
==        inet6 fe80::e5b:8fff:fe27:9a64  prefixlen 64  scopeid 0x20<link>
==        ether 0c:5b:8f:27:9a:64  txqueuelen 1000  (Ethernet)
==        RX packets 0  bytes 0 (0.0 B)
==        RX errors 1493  dropped 0  overruns 0  frame 0
==
==Note the RX errors.. ? 
==
==        TX packets 53  bytes 532885 (520.3 KiB)
==        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
==
==# route -n
==Kernel IP routing table
==Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
==0.0.0.0         10.8.219.201    0.0.0.0         UG    0      0        0 wwp0s26u1u5i1
==10.8.219.200    0.0.0.0         255.255.255.248 U     0      0        0 wwp0s26u1u5i1
==
==
==# ping 10.8.219.201
==PING 10.8.219.201 (10.8.219.201) 56(84) bytes of data.
==From 10.8.219.204 icmp_seq=1 Destination Host Unreachable
==From 10.8.219.204 icmp_seq=2 Destination Host Unreachable
==From 10.8.219.204 icmp_seq=3 Destination Host Unreachable
==From 10.8.219.204 icmp_seq=4 Destination Host Unreachable
==
==
==And pinging anywhere else doesn't work either.. (I also tried telnet/ssh/web - doesn't work).
==
==More ideas? 
==
==
==> This is one way to rewrite the addresses if you need to for a new
==> connection:
==> 
==>  perl -e 'print join(".", reverse map {hex} unpack("(A2)*", shift)),"\n"' C9DB080A
==> 
==
==This is handy, thanks!
==
==> 
==> 
==> Bjørn
==> 
==
==
==
==-- Pasi
==
==
---683441087-1015124440-1394789083=:5976--
