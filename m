From: "Gabriele Beltrame" <belgab@drvsource.net>
Subject: Random packet loss using IPsec with AES128-SHA1
Date: Wed, 16 Dec 2015 10:17:54 +0100
Message-ID: <000a01d137e2$afedd130$0fc97390$@drvsource.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip209.psaruba.com ([94.23.150.209]:59662 "EHLO webs.psaruba.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933879AbbLPJSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 04:18:17 -0500
Received: from amavis-7.psaruba.com (amavis-7.psaruba.com [192.168.255.7])
	by webs.psaruba.com (Postfix) with ESMTP id 22138881DC
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 10:18:15 +0100 (CET)
Received: from mail-hub.psaruba.com ([192.168.255.1])
	by amavis-7.psaruba.com (srv-psaruba-002.psaruba.com [192.168.255.7]) (amavisd-new, port 10026)
	with ESMTP id HTA9h5H9HrBY for <netdev@vger.kernel.org>;
	Wed, 16 Dec 2015 10:18:15 +0100 (CET)
Received: from mail-ext-sub.psaruba.com (mail-ext-sub.psaruba.com [IPv6:fc00:0:0:ff::4])
	by mail-hub.psaruba.com (Postfix) with ESMTP id E064BC403B
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 10:18:14 +0100 (CET)
Received: from Unimatrix (host127-236-dynamic.24-79-r.retail.telecomitalia.it [79.24.236.127])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: belgab@drvsource.net)
	by mail-ext-sub.psaruba.com (Postfix) with ESMTPSA id 1A4EA84039
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 10:18:12 +0100 (CET)
Content-Language: it
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm running a few Strongswan 5.3.* CentOS (Kernel 3.16.7, 4.2.6, 4.1.*)
instances on AWS to terminate VPNs between each other and/or to other
devices across the Internet.
While investigating some application issues, I've noticed that on every VPNs
I have random packet losses (from 1% to 4% over 100 to 300 requests sent).
This only happens when the two following conditions are met: (a) AES
encryption used, (b) IP packet size shorter than about (150+8+20)Bytes.

In tcpdump I can actually see all packets (requests and replies) being
"sent" from the router, but on destination server (on the same "LAN") they
are not being received... it's just like if the packet is being lost before
it's being actually serialized onto the network by the XEN NIC driver
Pinging form the vpn router itself always works fine though, never losing a
single packet...

Tested with Kernel 3.16.7, 4.2.6 and a AWS Amazon Linux instance (kernel
4.1.*).
Strongswan and libreswan shows the same issue, so it's not a Strongswan
issue.
Only AES CBS is affected... AES GCM is not affected, furthermore if I use
the Strongswan's kernel-libipsec plugin there is no packet loss.

To recap:
	a. it's not an instance type/size issue (I have the same issue on
everything I've tested with)
	b. it's not a Strongswan issue (I have the same
withlbreswan/Openswan)
	c. it's not a network/related issue (I can actually see on the
router all packets with tcpdump, they are just not received at the
destination (a host on the same network as the "vpn router")
	d. I only see this occurring with AES128 CBS DH2 (and possibly other
key sizes as well)... AES GCM is not affected, as well as 3DES and NULL
encryption
	e. Strongswan developers cannot reproduce the issue on their lab
(Strongswan issue #1220), so possibly there could be something wrong within
the Xen NIC driver
	f. ICMP packets bigger than around 178bytes (150+8+20) seem to not
be affected

Has somebody an idea about where the issue might be and how to
fix/workaround it (I cannot use 3DES and/or AES GCM everywhere and the
Strongswan's kernel-libipsec plugin taxes the CPU a lot more than the kernel
implementation)?

Regards,
Gabriele


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus
