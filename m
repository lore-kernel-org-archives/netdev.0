From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next] bnxt_en: Fix randconfig build errors.
Date: Fri, 27 Oct 2017 23:15:15 -0700
Message-ID: <20171027231515.1816951e@cakuba.netronome.com>
References: <1509170170-14847-1-git-send-email-michael.chan@broadcom.com>
        <427d0d07-2bb6-da88-d562-05f1a7f5f6f3@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <michael.chan@broadcom.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
To: Yunsheng Lin <linyunsheng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:16561 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750967AbdJ1GPY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Oct 2017 02:15:24 -0400
In-Reply-To: <427d0d07-2bb6-da88-d562-05f1a7f5f6f3@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Oct 2017 14:05:04 +0800, Yunsheng Lin wrote:
> Hi, Michael
> 
> On 2017/10/28 13:56, Michael Chan wrote:
> > Fix undefined symbols when CONFIG_VLAN_8021Q or CONFIG_INET is not set.
> > 
> > Fixes: 8c95f773b4a3 ("bnxt_en: add support for Flower based vxlan encap/decap offload")
> > Reported-by: Jakub Kicinski <kubakici@wp.pl>
> > Signed-off-by: Michael Chan <michael.chan@broadcom.com>
> > ---
> >  drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c | 6 ++++++
> >  1 file changed, 6 insertions(+)
> > 
> > diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
> > index 798d139..d5031f4 100644
> > --- a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
> > +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
> > @@ -904,6 +904,7 @@ static int bnxt_tc_resolve_tunnel_hdrs(struct bnxt *bp,
> >  				       struct bnxt_tc_l2_key *l2_info,
> >  				       struct net_device *real_dst_dev)
> >  {
> > +#ifdef CONFIG_INET  
> 
> Can we use #if IS_ENABLED(CONFIG_INET) here too?
> 
> I am not familiar with IS_ENABLED, just thought it would be
> good to be constistent because you are using IS_ENABLED below.

It's OK, CONFIG_INET can't be a module.

> >  	struct flowi4 flow = { {0} };
> >  	struct net_device *dst_dev;
> >  	struct neighbour *nbr;
> > @@ -925,6 +926,7 @@ static int bnxt_tc_resolve_tunnel_hdrs(struct bnxt *bp,
> >  	 */
> >  	dst_dev = rt->dst.dev;
> >  	if (is_vlan_dev(dst_dev)) {
> > +#if IS_ENABLED(CONFIG_VLAN_8021Q)

But here you should perhaps use IS_REACHABLE() otherwise when bnxt is
built in and 8021q is a module there could be trouble, no?
