From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Subject: RE: [PATCH] xfrm_policy delete security check misplaced
Date: Mon, 5 Mar 2007 09:33:27 -0600
Message-ID: <001301c75f3b$9efedb00$cc0a010a@tcssec.com>
References: <1172860190.31047.11.camel@localhost.localdomain>
Reply-To: <vyekkirala@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <jamesm@namei.org>,
	"Venkat Yekkirala" <vyekkirala@tcsfw4.tcs-sec.com>,
	<cxzhang@watson.ibm.com>, <sds@tycho.nsa.gov>,
	<latten@austin.ibm.com>
To: "'Eric Paris'" <eparis@parisplace.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:42112 "EHLO
	tcsfw4.tcs-sec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279AbXCEPe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 10:34:29 -0500
In-Reply-To: <1172860190.31047.11.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -2552,7 +2550,7 @@ static int pfkey_spdget(struct sock 
> *sk, struct sk_buff *skb, struct sadb_msg *h
>  		return -EINVAL;
>  
>  	xp = xfrm_policy_byid(XFRM_POLICY_TYPE_MAIN, dir, 
> pol->sadb_x_policy_id,
> -			      hdr->sadb_msg_type == SADB_X_SPDDELETE2);
> +			      hdr->sadb_msg_type == 
> SADB_X_SPDDELETE2, &err);
>  	if (xp == NULL)
>  		return -ENOENT;
I guess you meant to do this here?
	else if (err)
		return err;

Also, [Joy cc'd] deletions here needn't be audited?
