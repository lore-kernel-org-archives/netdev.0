From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 resend] netfilter: ipt_REJECT can't send TCP reset
Date: Thu, 16 Sep 2010 19:50:33 +0200
Message-ID: <4C9258E9.2050502@trash.net>
References: <1282029970-3111-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49335 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754202Ab0IPRug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 13:50:36 -0400
In-Reply-To: <1282029970-3111-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.08.2010 09:26, Changli Gao wrote:
> ip_route_me_harder can't create the route cache when the outdev is the same
> with the indev for the skbs whichout a valid protocol set.
> 
> __mkroute_input functions has this check:
> 1998         if (skb->protocol != htons(ETH_P_IP)) {
> 1999                 /* Not IP (i.e. ARP). Do not create route, if it is
> 2000                  * invalid for proxy arp. DNAT routes are always valid.
> 2001                  *
> 2002                  * Proxy arp feature have been extended to allow, ARP
> 2003                  * replies back to the same interface, to support
> 2004                  * Private VLAN switch technologies. See arp.c.
> 2005                  */
> 2006                 if (out_dev == in_dev &&
> 2007                     IN_DEV_PROXY_ARP_PVLAN(in_dev) == 0) {
> 2008                         err = -EINVAL;
> 2009                         goto cleanup;
> 2010                 }
> 2011         }
> 
> This patch gives the new skb a valid protocol to bypass this check. In order
> to make ipt_REJECT work with bridges, you also need to enable ip_forward.
> 
> This patch also fixes a regression. When we used skb_copy_expand(), we
> didn't have this issue stated above, as the protocol was properly set.

Applied to nf-2.6.git, thanks.
