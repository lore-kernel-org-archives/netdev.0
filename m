From: Yavor Goulishev <yavor@simplifymedia.com>
Subject: RE: [Patch] Establishing more than 64K outgoing TCP connections
Date: Fri, 7 Nov 2008 17:37:33 -0500
Message-ID: <241CE5A1B2AFFA4987A663380D74C0BB3FFDA39997@MBX73.ad2.softcom.biz>
References: <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887B@MBX73.ad2.softcom.biz>
	<20081107084555.GA13347@ioremap.net>
	<241CE5A1B2AFFA4987A663380D74C0BB3FFD15887F@MBX73.ad2.softcom.biz>
 <20081107.115401.214017400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "zbr@ioremap.net" <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xsmtp09.mail2web.com ([168.144.250.182]:47769 "EHLO
	xsmtp09.mail2web.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbYKGWil convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 17:38:41 -0500
In-Reply-To: <20081107.115401.214017400.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Therefore, if you use some idea like using saddr or daddr in the hash
> function, then a listening socket bind will have to walk the entire table
> to see if any socket exists already bound to that port.

It is not the entire table. It is O(number_of_local_interfaces).
In general, if you have more then one interface you either need to flatten the
ip/port space and have a smart way to access it in O(1) or you have the O(number_of_local_interfaces).
The case of ANY can be solved with special ANY interface. So you can get O(1) even there, but the space will grow.

--Yavor


