From: "Ristuccia, Brian" <bristuccia@starentnetworks.com>
Subject: RE: 2.6.20.7 mss negotiation and path mtu discovery mostly broken?
Date: Wed, 25 Apr 2007 16:11:51 -0400
Message-ID: <7CCD07160348804497EF29E9EA5560D7020F6213@exchtewks2.starentnetworks.com>
References: <7CCD07160348804497EF29E9EA5560D7020F6212@exchtewks2.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.starentnetworks.com ([12.38.223.203]:42177 "EHLO
	mx0.starentnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993059AbXDYUL5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 16:11:57 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mx0.starentnetworks.com (Postfix) with ESMTP id A66CC9005B
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2007 16:11:56 -0400 (EDT)
Received: from mx0.starentnetworks.com ([127.0.0.1])
	by localhost (mx0.starentnetworks.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 04403-07 for <netdev@vger.kernel.org>;
	Wed, 25 Apr 2007 16:11:51 -0400 (EDT)
Received: from exchtewks1.starentnetworks.com (exchtewks1.starentnetworks.com [12.33.233.52])
	by mx0.starentnetworks.com (Postfix) with ESMTP
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2007 16:11:51 -0400 (EDT)
Content-Class: urn:content-classes:message
In-Reply-To: <7CCD07160348804497EF29E9EA5560D7020F6212@exchtewks2.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I'm seeing a 
> problem where the kernel attempts to send packets with a MSS 
> larger than the one negotiated when the TCP connection is 
> established. Even after ICMP "can't fragment" messages 
> arrive, the kernel still attempts to increase the MSS rather 
> aggressively. The end result is extremely poor throughput 
> when sending to a network with a smaller MTU. 

I've tracked this problem to the TSO feature in the bnx2 driver. Turning
off TSO with "ethtool -K eth1 tso off" seems to work around the problem.
It appears that the bnx2 device is not using the correct mss when
performing segmentation offload. 

-Brian


"This email message and any attachments are confidential information of Starent Networks, Corp. The information transmitted may not be used to create or change any contractual obligations of Starent Networks, Corp.  Any review, retransmission, dissemination or other use of, or taking of any action in reliance upon this e-mail and its attachments by persons or entities other than the intended recipient is prohibited. If you are not the intended recipient, please notify the sender immediately -- by replying to this message or by sending an email to postmaster@starentnetworks.com -- and destroy all copies of this message and any attachments without reading or disclosing their contents. Thank you."
