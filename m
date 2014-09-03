From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: [net-next 05/15] i40e: Tell OS link is going down when calling
 set_phy_config
Date: Wed, 3 Sep 2014 10:27:59 -0700
Message-ID: <20140903102759.00000db7@intel.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1409304620-23251-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<5400BA63.7030307@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	<netdev@vger.kernel.org>, <nhorman@redhat.com>,
	<sassmann@redhat.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31338 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753813AbaICR2F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 13:28:05 -0400
In-Reply-To: <5400BA63.7030307@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Aug 2014 21:37:39 +0400
Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:

> On 08/29/2014 01:30 PM, Jeff Kirsher wrote:
> 
> > From: Catherine Sullivan <catherine.sullivan@intel.com>
> 
> > Since we don't seem to be getting an LSE telling us link is going
> > down during set_phy_config (but we do get an LSE telling us we are
> > coming back up), fake one for the OS and tell them link is going
> > down. Also do an atomic restart no matter what because there are
> > times the user may want to end with link up even if they started
> > with link down (like if they accidentally set it to a speed that
> > can't link and are trying to fix it).
> 
> > Change-ID: I0a642af9c1d0feb67bce741aba1a9c33bd349ed6
> > Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
> > Tested-by: Jim Young <jamesx.m.young@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >   drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 21
> > ++++++++++++++++++--- 1 file changed, 18 insertions(+), 3
> > deletions(-)
> 
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> > b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c index
> > de4ce0e..101be2f 100644 ---
> > a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c +++
> > b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c @@ -559,9 +559,17
> > @@ static int i40e_set_settings(struct net_device *netdev,
> > config.eeer = abilities.eeer_val; config.low_power_ctrl =
> > abilities.d3_lpan;
> >
> > -		/* If link is up set link and an so changes take
> > effect */
> > -		if (hw->phy.link_info.link_info & I40E_AQ_LINK_UP)
> > -			config.abilities |=
> > I40E_AQ_PHY_ENABLE_ATOMIC_LINK;
> > +		/* set link and an so changes take effect */
> 
>     Can't parse this comment, probably a word is missing?
> 
> WBR, Sergei

"and an" should be "and AN" I think - AN standing in for
auto negotiation.

Agreed the comment needs fixing up.  Should probably just say
"auto negotiation"

- Greg

> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
