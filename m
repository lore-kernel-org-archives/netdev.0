From: "Prashant Batra (prbatra)" <prbatra@cisco.com>
Subject: ipsec tunnel with different inner and outer ip families
Date: Fri, 13 Jan 2012 13:51:34 +0530
Message-ID: <B97B134FACB2024DB45F524AB0A7B7F2058AF99D@XMB-BGL-419.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-1.cisco.com ([72.163.197.25]:2938 "EHLO
	bgl-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936Ab2AMIVz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 03:21:55 -0500
Received: from xbh-bgl-411.cisco.com (xbh-bgl-411.cisco.com [72.163.129.201])
	by bgl-core-1.cisco.com (8.14.3/8.14.3) with ESMTP id q0D8LcHN007833
	for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 08:21:38 GMT
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Does linux 2.6.* support an IPSec tunnel with different family of inner=
 and outer addresses , like v4 in v6 or v6 in v4.
After trying ip xfrm * from user space, the utility doesn't seem to acc=
ept two different families in a single command.

#ip xfrm policy add dir out src 172.168.68.1/32 dst 172.168.68.2/32 tmp=
l src 2001:db8:0:242::36/128 dst 2001:db8:0:242::37/128 proto esp=A0 mo=
de tunnel
Error: an inet prefix is expected rather than "2001:db8:0:242::36/128".

So, I tried sending a NETLINK SPD add message) from user space with, se=
lector as v4 addresses and tmpl as v6 address.
Policy got added but kernel doesn't seem to be interpreting the address=
es correctly.

src 172.16.80.1/32 dst 0.0.0.0/0
=A0=A0=A0=A0=A0=A0=A0 dir out priority 1024
=A0=A0=A0=A0=A0=A0=A0 tmpl=A0=A0=A0 src 32.1.13.184 dst 32.1.13.184=A0=A0=
 /* I gave ipv6 addresses here*/
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 proto esp spi 0x00000000 =
reqid 0 mode tunnel

Can someone help me with this?

Regards,
Prashant.
