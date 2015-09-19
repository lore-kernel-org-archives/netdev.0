From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v2] geneve: remove use of internal IP header when calling
 IP_ECN_decapsulate
Date: Fri, 18 Sep 2015 21:36:38 -0400
Message-ID: <20150919013638.GF18191@tuxdriver.com>
References: <1442510271-10110-1-git-send-email-linville@tuxdriver.com>
 <1442522094-876-1-git-send-email-linville@tuxdriver.com>
 <CAEP_g=-EGH-hfCRYQ8WStY2btq=1g-y=g=PvC_e-aC8QZKugJA@mail.gmail.com>
 <20150918204023.GD18191@tuxdriver.com>
 <CAEP_g=_aDApp8+Uj8JOpg=jzxEs73XzSufgWzA-ODpfXS-ss-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49782 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217AbbISBpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 21:45:14 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=_aDApp8+Uj8JOpg=jzxEs73XzSufgWzA-ODpfXS-ss-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 02:49:30PM -0700, Jesse Gross wrote:
> On Fri, Sep 18, 2015 at 1:40 PM, John W. Linville
> <linville@tuxdriver.com> wrote:
> > On Fri, Sep 18, 2015 at 01:30:36PM -0700, Jesse Gross wrote:
> >> On Thu, Sep 17, 2015 at 1:34 PM, John W. Linville
> >> <linville@tuxdriver.com> wrote:
> >> > This seems to have been a "thinko".  IP_ECN_decapsulate needs info
> >> > from both internal and external headers.
> >> >
> >> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> >>
> >> This looks good to me although I realized that the transmit path is
> >> also conditional based on !collect_md metadata. I suppose that means
> >> that this difference is intentional and I guess I could see arguments
> >> either way but I still think it is better to be consistent across
> >> different code paths in this respect.
> >
> > I'm happy with the v2 patch if you are. :-)
> 
> I'm happy with this part of the code path after this patch. However,
> my concern was that this patch, while correct, will make receive
> inconsistent with transmit. Presumably we should update the transmit
> side as well.

Oh, sorry -- I missed your point.  You mean something like this?

@@ -812,19 +815,16 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev)
		if (unlikely(err))
			goto err;
 
-		tos = key->tos;
+		tos = ip_tunnel_ecn_encap(key->tos, iip, skb);
		ttl = key->ttl;
		df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;

Am I understanding now?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
