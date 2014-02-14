From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next 05/14] i40evf: fix up strings in init task
Date: Fri, 14 Feb 2014 23:53:08 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D65517F5F@FMSMSX113.amr.corp.intel.com>
References: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
	 <1392418688-23895-6-git-send-email-aaron.f.brown@intel.com>
 <1392421409.12157.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Joe Perches <joe@perches.com>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32752 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838AbaBNXxL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 18:53:11 -0500
In-Reply-To: <1392421409.12157.3.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Friday, February 14, 2014 3:43 PM
> To: Brown, Aaron F
> Cc: davem@davemloft.net; Williams, Mitch A; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com; Brandeburg, Jesse
> Subject: Re: [net-next 05/14] i40evf: fix up strings in init task
> 
> On Fri, 2014-02-14 at 14:57 -0800, Aaron Brown wrote:
> > From: Mitch Williams <mitch.a.williams@intel.com>
> 
> Hello.
> 
> > Make sure errors are reported at the correct log level, quit printing
> > the function name every time, and make the messages more consistent in
> > format.
> 
> > diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> []
> > @@ -1939,14 +1939,14 @@ static void i40evf_init_task(struct work_struct
> *work)
> >  		adapter->flags &= ~I40EVF_FLAG_RESET_PENDING;
> >  		err = i40e_set_mac_type(hw);
> >  		if (err) {
> > -			dev_info(&pdev->dev, "%s: set_mac_type failed: %d\n",
> > -				__func__, err);
> > +			dev_err(&pdev->dev, "Failed to set MAC type (%d)\n",
> > +				err);
> >  		goto err;
> >  		}
> >  		err = i40evf_check_reset_complete(hw);
> >  		if (err) {
> > -			dev_info(&pdev->dev, "%s: device is still in reset (%d).\n",
> > -				__func__, err);
> > +			dev_err(&pdev->dev, "Device is still in reset (%d).\n",
> > +				err);
> 
> 
> Look at the lines above and below here.
> 
> If you're going to be consistent, can you please
> remove the unnecessary period before the newline.
> 
> >  			goto err;
> >  		}
> >  		hw->aq.num_arq_entries = I40EVF_AQ_LEN;
> > @@ -1956,14 +1956,14 @@ static void i40evf_init_task(struct work_struct
> *work)
> >
> >  		err = i40evf_init_adminq(hw);
> >  		if (err) {
> > -			dev_info(&pdev->dev, "%s: init_adminq failed: %d\n",
> > -				__func__, err);
> > +			dev_err(&pdev->dev, "Failed to init Admin Queue (%d)\n",
> > +				err);
> >  			goto err;
> >  		}
> >  		err = i40evf_send_api_ver(adapter);
> >  		if (err) {
> > -			dev_info(&pdev->dev, "%s: unable to send to PF (%d)\n",
> > -				__func__, err);
> > +			dev_err(&pdev->dev, "Unable to send to PF (%d)\n",
> > +				err);
> >  			i40evf_shutdown_adminq(hw);
> >  			goto err;
> >  		}
> 
> []
> 
> > @@ -1998,8 +1998,7 @@ static void i40evf_init_task(struct work_struct
> *work)
> >  				 sizeof(struct i40e_virtchnl_vsi_resource));
> >  			adapter->vf_res = kzalloc(bufsz, GFP_KERNEL);
> >  			if (!adapter->vf_res) {
> > -				dev_err(&pdev->dev, "%s: unable to allocate memory\n",
> > -					__func__);
> > +				dev_err(&pdev->dev, "Unable to allocate memory for vf
> resources.\n");
> 
> Unnecessary OOM.
> Allocs failures already have one and a dump_stack().
> 
> > @@ -2022,7 +2021,7 @@ static void i40evf_init_task(struct work_struct
> *work)
> >  			adapter->vsi_res = &adapter->vf_res->vsi_res[i];
> >  	}
> >  	if (!adapter->vsi_res) {
> > -		dev_info(&pdev->dev, "%s: no LAN VSI found\n", __func__);
> > +		dev_err(&pdev->dev, "No LAN VSI found.\n");
> 
> Adding unnecessary periods.
> 
> > @@ -2053,9 +2052,8 @@ static void i40evf_init_task(struct work_struct
> *work)
> >
> >  	/* The HW MAC address was set and/or determined in sw_init */
> >  	if (!is_valid_ether_addr(adapter->hw.mac.addr)) {
> > -		dev_info(&pdev->dev,
> > -			"Invalid MAC address %pMAC, using random\n",
> > -			adapter->hw.mac.addr);
> > +		dev_info(&pdev->dev, "Invalid MAC address %pMAC, using
> random.\n",
> 
> And here too.
> 
Joe, thanks for your review. We'll ditch the OOM message and I'll add a reminder to myself to scrub the rest of the driver for more of these.

With regard to periods on the end of log messages, is this a hard rule? The grammar pedant in me likes to see periods on the end of sentences, so I tend to add them. However, I see that CodingStyle says, "Kernel messages do not have to be terminated with a period." Perhaps we should change that to say "should not" if it is considered a rule.

Either way, we'll respin the patch.

-Mitch
