From: Brian Russell <brussell@brocade.com>
Subject: [PATCH net-next 0/2] NSH and VxLAN-GPE
Date: Thu, 11 Feb 2016 10:35:11 +0000
Message-ID: <1455186914-8952-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:54783 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750925AbcBKKfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 05:35:34 -0500
Received: from pps.filterd (m0048192.ppops.net [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1BASe0Y021796
	for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 02:35:33 -0800
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0b-000f0801.pphosted.com with ESMTP id 20wh08brxu-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 02:35:33 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add a new module to support encap/decap of Network
Service Header (NSH) as defined in:

https://tools.ietf.org/html/draft-ietf-sfc-nsh-01

Both NSH Type 1 and Type 2 metadata are supported with a simple registration
hook to allow listeners to register to see packets with Type 1 or a specific
class of Type 2 metadata. NSH could be added to packets sent over a variety
of link types, eg. VxLAN, GRE, ethernet.

Also included is an extension to VxLAN to handle the Generic Protocol
Extension (GPE) as defined in:

https://tools.ietf.org/html/draft-ietf-nvo3-vxlan-gpe-01

This allows multi-protocol encapsulation over the VxLAN so IPv4, IPv6, MPLS
and NSH encapsulated packets can be sent and received in addition to ethernet
frames. Non-ethernet frames are sent to the default destination, which
requires that the remote option is specified when creating the VxLAN device.

I've tested this by using a netfilter module to encap some app-specific
metadata in NSH type 2 and send it over the VxLAN and a listener module
to receive the corresponding decap'd metadata.

I'm also submitting a corresponding patch for iproute2 to add the gpe option
to the "ip link add type vxlan" command.

Brian Russell (2):
  nsh: encapsulation module
  vxlan: support GPE/NSH

 drivers/net/vxlan.c           | 139 ++++++++++++++--
 include/net/nsh.h             | 158 ++++++++++++++++++
 include/net/vxlan.h           |  40 ++++-
 include/uapi/linux/if_ether.h |   1 +
 include/uapi/linux/if_link.h  |   1 +
 net/ipv4/Kconfig              |  10 ++
 net/ipv4/Makefile             |   1 +
 net/ipv4/nsh.c                | 362 ++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 698 insertions(+), 14 deletions(-)
 create mode 100644 include/net/nsh.h
 create mode 100644 net/ipv4/nsh.c

-- 
2.1.4
