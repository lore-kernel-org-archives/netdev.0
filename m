From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next v2 11/16] i40e: remove chatty log messages
Date: Fri, 20 Dec 2013 17:40:23 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D654E34C9@FMSMSX113.amr.corp.intel.com>
References: <1387557965-13241-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1387557965-13241-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <52B489ED.3010704@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42621 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874Ab3LTRmL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 12:42:11 -0500
In-Reply-To: <52B489ED.3010704@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> Sent: Friday, December 20, 2013 10:18 AM
> To: Kirsher, Jeffrey T; davem@davemloft.net; Williams, Mitch A
> Cc: netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com;
> Brandeburg, Jesse
> Subject: Re: [net-next v2 11/16] i40e: remove chatty log messages
> 
> On 12/20/2013 07:46 PM, Jeff Kirsher wrote:
> 
> > From: Mitch Williams <mitch.a.williams@intel.com>
> 
> > Don't complain when we disable queues that are already disable, or
> > enable them when they're already enabled. This removes a bunch of bogus
> > log messages that we see at every VF reset.
> 
> > Change-Id: Ia127be572abdccc48a53d8c43f8a07b8bb920de1
> > Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >   drivers/net/ethernet/intel/i40e/i40e_main.c | 16 +++-------------
> >   1 file changed, 3 insertions(+), 13 deletions(-)
> 
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > index c0f78bc..38e07e6 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > @@ -2988,21 +2988,11 @@ static int i40e_vsi_control_tx(struct i40e_vsi
> *vsi, bool enable)
> >   		} while (j-- && ((tx_reg >> I40E_QTX_ENA_QENA_REQ_SHIFT)
> >   			       ^ (tx_reg >> I40E_QTX_ENA_QENA_STAT_SHIFT)) & 1);
> >
> > -		if (enable) {
> > -			/* is STAT set ? */
> > -			if ((tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
> > -				dev_info(&pf->pdev->dev,
> > -					 "Tx %d already enabled\n", i);
> > +		/* Skip if the queue is already in the requested state */
> > +		if (enable && (tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
> >   				continue;
> 
>     This line seems over-indented now.
> 
> > -			}
> > -		} else {
> > -			/* is !STAT set ? */
> > -			if (!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
> > -				dev_info(&pf->pdev->dev,
> > -					 "Tx %d already disabled\n", i);
> > +		if (!enable && !(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
> >   				continue;
> 
>     This one too.
> 
> WBR, Sergei

Sergei, if you look at the source instead of the patch, you'll see that these are correct. The whole thing is inside a for loop, so it should properly be indented two tabs.

-Mitch
