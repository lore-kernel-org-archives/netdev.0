From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] improved xfrm_audit_log() patch
Date: Tue, 07 Aug 2007 18:32:25 -0700 (PDT)
Message-ID: <20070807.183225.02298028.davem@davemloft.net>
References: <200708022056.l72KulGS019506@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: latten@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59963
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934485AbXHHBc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 21:32:28 -0400
In-Reply-To: <200708022056.l72KulGS019506@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joy Latten <latten@austin.ibm.com>
Date: Thu, 2 Aug 2007 15:56:47 -0500

> @@ -426,10 +426,15 @@ struct xfrm_audit
>  };
>  
>  #ifdef CONFIG_AUDITSYSCALL
> -extern void xfrm_audit_log(uid_t auid, u32 secid, int type, int result,
> -		    struct xfrm_policy *xp, struct xfrm_state *x);
> +extern void xfrm_audit_log(struct xfrm_audit audit_info, int result,
> +			   __be32 flowid, struct xfrm_policy *xp, 
> +			   struct xfrm_state *x, char *buf);

Passing audit_info as an aggregate argument puts them into
previous argument registers, or if they are not enough it
goes either partially of wholly onto the stack, depending
upon architecture.

In fact you've made the argument register usage worse than
in your previous revision. :-/

Perhaps you meant to pass "struct xfrm_audit *" instead?
