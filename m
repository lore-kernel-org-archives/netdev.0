From: Ben Greear <greearb@candelatech.com>
Subject: SCTP and IP_TOS
Date: Mon, 12 Aug 2013 10:00:02 -0700
Message-ID: <52091492.9060904@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50487 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756725Ab3HLRAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 13:00:03 -0400
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r7CH02w1023959
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 10:00:02 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I notice that I read 0x2 as IP_TOS getsockopt on an SCTP socket configured
for streaming mode.

Looks to me like the reason is that SCTP uses a socket type of SCTP_SOCKET_TCP
and the ipv4/ip_sockglue.c code is only masking out ECN for SOCK_STREAM types.

Is this per design, or should the ip_sockglue.c mask out ECN for SCTP_SOCKET_TCP
types as well?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
