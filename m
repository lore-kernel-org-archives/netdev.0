From: Jeff Haran <jharan@Brocade.COM>
Subject: kernel never returns rtm_protocol of RTPROT_RA?
Date: Tue, 13 Apr 2010 19:04:54 -0700
Message-ID: <D67825C5985D0647BE40A5F5B0B70D110D404A3AB5@HQ-EXCH-7.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:39319 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754369Ab0DNCQD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 22:16:03 -0400
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.3/8.14.3) with SMTP id o3E24xRl031289
	for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 19:04:59 -0700
Received: from hq-exedge.brocade.com (hq-exedge.brocade.com [66.243.153.83])
	by mx0b-000f0801.pphosted.com with ESMTP id n52qa01h0-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 19:04:58 -0700
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Perhaps I am misreading the kernel sources, but it looks to me like an IPv6 default gateway that is discovered via the receipt of the Router Advertisement will not be reported in a netlink RTM_NEWROUTE message with the rtm_protocol field == RTPROT_RA, though that seems to be the defined purpose for RTPROT_RA. It seems like such addresses are going to be reported with rtm_protocol == RTPROT_KERNEL.

This is what I observe reading the sources to our old kernel (2.6.14) and actually running the data through it, and later sources seem to be doing the same thing though I haven't studied them as closely.

Is this the expected behavior?

Does anybody see any problems if I change rt6_fill_node() to put RTPROT_RA into rtm_protocol when rt6i_flags has both the RTF_ADDRCONF and RTF_DEFAULT bits set?

I am writing an application that distinguishes different sources of IPv6 routes and would like be able to count on RTPROT_RA meaning the default router address originated from a Router Advertisements.

Please include my email address in response as I do not subscribe to this list.

Thanks,

Jeff Haran
Brocade

