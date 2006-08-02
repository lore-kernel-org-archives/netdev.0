From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/23] [PATCH] [XFRM]: Restrict authentication
 algorithm only when inbound transformation protocol is IPsec.
Date: Tue, 01 Aug 2006 17:18:26 -0700 (PDT)
Message-ID: <20060801.171826.45739592.davem@davemloft.net>
References: <1154165438334-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2276
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750841AbWHBAS2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 20:18:28 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <1154165438334-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Sat, 29 Jul 2006 18:30:38 +0900

> -		(tmpl->aalgos & (1<<x->props.aalgo)) &&
> +		((tmpl->aalgos & (1<<x->props.aalgo)) ||
> +		 !(xfrm_id_proto_match(tmpl->id.proto, IPSEC_PROTO_ANY))) &&

This is another instance of a xfrm_id_proto_match() call
which will always evaluate to true, because the userproto
argument is IPSEC_PROTO_ANY.

+static inline int xfrm_id_proto_match(u8 proto, u8 userproto)
+{
+	return (userproto == IPSEC_PROTO_ANY || proto == userproto);
+}

Can you elaborate on how this is supposed to work?  It does not
seem intentional that all of these calls will always evaluate
to true.

