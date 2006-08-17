From: James Morris <jmorris@namei.org>
Subject: Re: [PATCHv2 2.6.17] net/ipv6/udp.c: remove duplicate udp_get_port
 code
Date: Thu, 17 Aug 2006 10:56:40 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608171054560.19149@d.namei>
References: <200608171325.47349@strip-the-willow>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:48604 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932516AbWHQO4m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 10:56:42 -0400
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200608171325.47349@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Aug 2006, gerrit@erg.abdn.ac.uk wrote:

> -			if (inet2->num == snum &&
> -			    sk2 != sk &&
> -			    !ipv6_only_sock(sk2) &&
> -			    (!sk2->sk_bound_dev_if ||
> -			     !sk->sk_bound_dev_if ||
> -			     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&


> +		sk_for_each(sk2, node, head)
> +			if (inet_sk(sk2)->num == snum                        &&
> +			    sk2 != sk                                        &&
> +			    (!sk2->sk_reuse        || !sk->sk_reuse)         &&
> +			    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
> +			     || sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&


Doesn't this change the behavior for IPV6_V6ONLY sockets ?


- James
-- 
James Morris
<jmorris@namei.org>
