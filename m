From: Julian Anastasov <ja@ssi.bg>
Subject: Re[2]:  [PATCH 05/19] netfilter: nf_conntrack_ipv6: improve
 fragmentation handling
Date: Wed, 22 Aug 2012 10:16:59 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1208221014000.1698@ja.ssi.bg>
References: <mdaatbj.b2f3561b17fe4f00a6e947611a0959a1@obelix.schillstrom.com> <alpine.LFD.2.00.1208220954260.1698@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1446726840-1345619819=:1698"
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:52401 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460Ab2HVHP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2012 03:15:26 -0400
In-Reply-To: <alpine.LFD.2.00.1208220954260.1698@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1446726840-1345619819=:1698
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Wed, 22 Aug 2012, Julian Anastasov wrote:

> On Wed, 22 Aug 2012, Hans Schillstrom wrote:
> 
> > >Perhaps we could change/fix the MTU check in IPVS?
> > >(This would also solve issues I've seen with TSO/GSO frames, hitting
> > >this code path).
> > >
> > I ran into this as well, 
> > try this for the mtu check.
> > 
> >        if ((!skb->local_df && skb->len > mtu && !skb_is_gso(skb)) ||
> >            (IP6CB(skb)->frag_max_size && IP6CB(skb)->frag_max_size > mtu)) {
> 
> 	Better without local_df check, it is our job to
> set it.

	Ops, sorry. It seems now nf_ct_frag6_reasm (Patch 02/18)
will set head->local_df = 1, so we should check local_df
as Hans said.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1446726840-1345619819=:1698--
