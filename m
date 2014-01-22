From: Sridhar Samudrala <sri@us.ibm.com>
Subject: VLAN ID 0 with priority tagging
Date: Wed, 22 Jan 2014 15:49:21 -0800
Message-ID: <52E05901.6050601@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:43662 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbaAVXtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 18:49:25 -0500
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Wed, 22 Jan 2014 16:49:24 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 3B63D1FF001E
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 16:48:48 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0MNn65q9896250
	for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 00:49:06 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0MNnK2Z010196
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 16:49:20 -0700
Received: from [9.65.13.124] (sig-9-65-13-124.mts.ibm.com [9.65.13.124])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id s0MNnJ22010175
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 16:49:20 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am trying to send a packet with VLAN ID 0 and non-zero priority.

The VLAN interfaces are created on 2 hosts using
     ip link add link eth1 eth1.0 type vlan id 0 egress-qos-map 0:2

When i try to send a packet using ping/arping, on the sender side tcpdump
shows that the VLAN tag is added with ID 0 and priority 2.

However, the receiver is receiving the packet with vlan tag stripped.

I am seeing the same behavior with multiple NICs and also with a switch in
between the 2 hosts or with the 2 hosts connected over loopback cable.

It looks as if the driver on the send side is stripping the tag if vlan 
id is 0.
Is this correct behavior or a bug?
Any clues on how to  get priority tagging to work with vlan id 0?

Thanks
Sridhar
