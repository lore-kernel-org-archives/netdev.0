From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][INET 1/2]: Drop the inet_inherit_port() call.
Date: Thu, 17 Apr 2008 23:17:52 -0700 (PDT)
Message-ID: <20080417.231752.178453811.davem@davemloft.net>
References: <480773EA.2000302@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@redhat.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56016
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753401AbYDRGRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 02:17:54 -0400
In-Reply-To: <480773EA.2000302@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 17 Apr 2008 19:59:38 +0400

> As I can see from the code, two places (tcp_v6_syn_recv_sock and
> dccp_v6_request_recv_sock) that call this one already run with
> BHs disabled, so it's safe to call __inet_inherit_port there.
> 
> Besides (in case I missed smth with code review) the calltrace
> tcp_v6_syn_recv_sock
>  `- tcp_v4_syn_recv_sock
>      `- __inet_inherit_port
> and the similar for DCCP are valid, but assumes BHs to be disabled.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

I agree with you analysis, all of these sites have BH disabled,
patch applied.
