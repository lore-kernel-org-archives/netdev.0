From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 v2 3/3] sctp: Add a valid address list in
 association local
Date: Thu, 14 Apr 2011 09:33:36 +0800
Message-ID: <4DA64EF0.30506@cn.fujitsu.com>
References: <115A4380-6E63-4014-BD24-04A29472ACCD@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50157 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754310Ab1DNBd2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:33:28 -0400
In-Reply-To: <115A4380-6E63-4014-BD24-04A29472ACCD@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> When the SCTP association transmits an ASCONF with ADD_IP_ADDRESS, that association cannot use the adding address until it receives ASCONF-ACK.  
> This patch prevents that associations that do not receive ASCONF-ACK use the adding address.

The new adding address is marked SCTP_ADDR_NEW, and cannot use
in LKSCTP until received ASCONF-ACK and marked as SCTP_ADDR_SRC.
So, add this valid address list is unnecessary.

I guess you want to fix the route lookup issue?

If it is, the only thing we need to fix is the lookup of route. If we can not
found a valid dst for transport, we can try address marked with SCTP_ADDR_NEW.


