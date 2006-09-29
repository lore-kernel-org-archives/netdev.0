From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 1/1] NetLabel: secid reconciliation support
Date: Fri, 29 Sep 2006 17:20:09 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF3A5@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: jmorris@namei.org, sds@tycho.nsa.gov, method@gentoo.org,
	kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:60588 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161386AbWI2VU3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 17:20:29 -0400
To: paul.moore@hp.com, netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -3672,16 +3674,20 @@ static int selinux_skb_flow_in(struct sk
>  	if (err)
>  		goto out;
>  
> -	if (xfrm_sid) {
> -		err = security_transition_sid(xfrm_sid, skb->secmark,
> -						
> SECCLASS_PACKET, &trans_sid);
> -		if (err)
> -			goto out;
> +	if (xfrm_sid)
> +		skb->secmark = xfrm_sid;
>  
> -		skb->secmark = trans_sid;
> -	}
> +	err = selinux_netlbl_skb_sid(skb, skb->secmark, &nlbl_sid);

I take it nlbl_sid here will be 0 if netlabel is NOT configured
for the traffic correct?

> --- net-2.6.orig/security/selinux/ss/mls.c
> +++ net-2.6/security/selinux/ss/mls.c
> @@ -547,7 +547,7 @@ int mls_compute_sid(struct context *scon
>  				                     
&rtr->target_range);
>  			}
>  		}
> -		else if (tclass == SECCLASS_PACKET)
> +		if (tclass == SECCLASS_PACKET)

What's the purpose of getting rid of "else" above?

I haven't reviewed the netlbl native changes, but the hooks.c changes
seem ok to me.
