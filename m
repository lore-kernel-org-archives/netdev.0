From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCHv2 2.6.17] net/ipv6/udp.c: remove duplicate udp_get_port
 code
Date: Fri, 18 Aug 2006 00:18:20 +0900 (JST)
Message-ID: <20060818.001820.05196705.yoshfuji@linux-ipv6.org>
References: <200608171325.47349@strip-the-willow>
	<Pine.LNX.4.64.0608171054560.19149@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:22800 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S964980AbWHQPQi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 11:16:38 -0400
To: gerrit@erg.abdn.ac.uk, jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0608171054560.19149@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

In article <Pine.LNX.4.64.0608171054560.19149@d.namei> (at Thu, 17 Aug 2006 10:56:40 -0400 (EDT)), James Morris <jmorris@namei.org> says:

> On Thu, 17 Aug 2006, gerrit@erg.abdn.ac.uk wrote:
> 
> > -			if (inet2->num == snum &&
> > -			    sk2 != sk &&
> > -			    !ipv6_only_sock(sk2) &&
> > -			    (!sk2->sk_bound_dev_if ||
> > -			     !sk->sk_bound_dev_if ||
> > -			     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
> 
> 
> > +		sk_for_each(sk2, node, head)
> > +			if (inet_sk(sk2)->num == snum                        &&
> > +			    sk2 != sk                                        &&
> > +			    (!sk2->sk_reuse        || !sk->sk_reuse)         &&
> > +			    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
> > +			     || sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
> 
> 
> Doesn't this change the behavior for IPV6_V6ONLY sockets ?

It is tested in ipv4_rcv_saddr_equal() (called vi saddr_cmp), isn't it?

--yoshfuji
