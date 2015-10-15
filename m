From: "Sullivan, Catherine" <catherine.sullivan@intel.com>
Subject: RE: [net-next 05/17] i40e: Change some messages from info to debug
 only
Date: Thu, 15 Oct 2015 16:49:14 +0000
Message-ID: <E8A77B2FB54C194393A5C2A8E3ED167827A62103@CRSMSX102.amr.corp.intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1444902004-14433-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <1444902884.2718.41.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Parikh, Neerav" <neerav.parikh@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>
To: Joe Perches <joe@perches.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:56461 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752482AbbJOQtm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 12:49:42 -0400
In-Reply-To: <1444902884.2718.41.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Joe Perches [mailto:joe@perches.com]
> Sent: Thursday, October 15, 2015 2:55 AM
> 
> On Thu, 2015-10-15 at 02:39 -0700, Jeff Kirsher wrote:
> > From: Neerav Parikh <neerav.parikh@intel.com>
> >
> > There are several error messages that have been printing when there is
> > no functional issue. These messages should be available at debug
> > message level only.
> []
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> > b/drivers/net/ethernet/intel/i40e/i40e_main.c
> []
> > @@ -6593,9 +6593,9 @@ static void i40e_reset_and_rebuild(struct i40e_pf
> *pf, bool reinit)
> >  	/* make sure our flow control settings are restored */
> >  	ret = i40e_set_fc(&pf->hw, &set_fc_aq_fail, true);
> >  	if (ret)
> > -		dev_info(&pf->pdev->dev, "set fc fail, err %s aq_err %s\n",
> > -			 i40e_stat_str(&pf->hw, ret),
> > -			 i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
> > +		dev_dbg(&pf->pdev->dev, "setting flow control: ret = %s
> last_status = %s\n",
> > +			i40e_stat_str(&pf->hw, ret),
> > +			i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
> []
> > @@ -10333,10 +10339,9 @@ static int i40e_probe(struct pci_dev *pdev,
> const struct pci_device_id *ent)
> >  	/* get the requested speeds from the fw */
> >  	err = i40e_aq_get_phy_capabilities(hw, false, false, &abilities, NULL);
> >  	if (err)
> > -		dev_info(&pf->pdev->dev,
> > -			 "get phy capabilities failed, err %s aq_err %s,
> advertised speed settings may not be correct\n",
> > -			 i40e_stat_str(&pf->hw, err),
> > -			 i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
> > +		dev_dbg(&pf->pdev->dev, "get requested speeds ret =  %s
> last_status =  %s\n",
> > +			i40e_stat_str(&pf->hw, err),
> > +			i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
> >  	pf->hw.phy.link_info.requested_speeds = abilities.link_speed;
> >
> >  	/* get the supported phy types from the fw */
> 
> 
> Perhaps these 2 are functional issues and should remain dev_info or maybe
> upgraded to notice or err
> 
> 
They aren't functional issues right now. Both of these are actually failures from the get_phy_capabilities call, so the only problem would be the phy information the driver has stored being slightly out of date, and in this case it is out of date for such a short period of time that it doesn't have an effect. We don't want to alarm people with an error message that has no functional impact right now, but we wanted to leave it in at the debug level in case it does have a functional impact in the future we still have a way to see the problem. 
