From: Brian Russell <brussell@brocade.com>
Subject: [PATCH net-next v3 0/3] NSH and VxLAN-GPE
Date: Tue, 1 Mar 2016 11:11:46 +0000
Message-ID: <1456830709-32052-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:58964 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752688AbcCALMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 06:12:08 -0500
Received: from pps.filterd (m0000700.ppops.net [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u21B5w3E029033
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2016 03:12:06 -0800
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0b-000f0801.pphosted.com with ESMTP id 21baa5frhx-2
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 03:12:05 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add a new module to support encap/decap of Network
Service Header (NSH) as defined in:

https://tools.ietf.org/html/draft-ietf-sfc-nsh-01

Both NSH Type 1 and Type 2 metadata are supported with a simple registration
hook to allow listeners to register to see packets with Type 1 or a specific
class of Type 2 metadata. NSH could be added to packets sent over a variety
of link types, eg. VxLAN, GRE, ethernet.

v2 - fix copyright notices and tidy up use of types

v3 - fix various style issues in nsh module
     remove VxLAN-GPE changes
     add nsh logging module as example
     add nsh netfilter encap target as example

The previous version included mods to allow NSH over VxLAN-GPE but I've
withdrawn this as VxLAN-GPE is currently being added in a much more complete
patchset. My intention would be to add NSH support on top of that once it's
applied.

I've added the NSH logging module to illustrate the use of the simple
mechanism to register for incoming decap'd NSH metadata.

I've added the NSH netfilter target to illustrate metadata being NSH
encap'd.

Brian Russell (3):
  nsh: encapsulation module
  nsh: logging module
  nsh: netfilter target

 include/net/nsh.h                     | 147 +++++++++++++++
 include/uapi/linux/if_ether.h         |   1 +
 include/uapi/linux/netfilter/xt_NSH.h |  25 +++
 net/ipv4/Kconfig                      |  18 ++
 net/ipv4/Makefile                     |   2 +
 net/ipv4/nsh.c                        | 335 ++++++++++++++++++++++++++++++++++
 net/ipv4/nsh_log.c                    | 135 ++++++++++++++
 net/netfilter/Kconfig                 |   9 +
 net/netfilter/Makefile                |   1 +
 net/netfilter/xt_NSH.c                |  95 ++++++++++
 10 files changed, 768 insertions(+)
 create mode 100644 include/net/nsh.h
 create mode 100644 include/uapi/linux/netfilter/xt_NSH.h
 create mode 100644 net/ipv4/nsh.c
 create mode 100644 net/ipv4/nsh_log.c
 create mode 100644 net/netfilter/xt_NSH.c

-- 
2.1.4
