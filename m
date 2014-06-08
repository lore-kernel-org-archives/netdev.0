From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next 11/15] i40e/i40evf: remove chatty reset messages
Date: Sun, 8 Jun 2014 19:06:57 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D656C9968@FMSMSX113.amr.corp.intel.com>
References: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1402238037-20661-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <1402248859.6328.13.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Joe Perches <joe@perches.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17284 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756430AbaFHTHH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 15:07:07 -0400
In-Reply-To: <1402248859.6328.13.camel@joe-AO725>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Sunday, June 08, 2014 10:34 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Williams, Mitch A; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 11/15] i40e/i40evf: remove chatty reset messages
> 
> On Sun, 2014-06-08 at 07:33 -0700, Jeff Kirsher wrote:
> > Because some of these message are inside if statements, we have to
> > rejigger the brackets at the same time to keep our coding style
> > consistent.
> 
> trivia:
> 
> > diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> []
> > @@ -1503,12 +1500,10 @@ static void i40evf_reset_task(struct work_struct
> *work)
> >  	for (i = 0; i < I40EVF_RESET_WAIT_COUNT; i++) {
> >  		rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
> >  			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
> > -		if (rstat_val == I40E_VFR_VFACTIVE) {
> > -			dev_info(&adapter->pdev->dev, "Reset complete,
> reinitializing\n");
> > +		if (rstat_val == I40E_VFR_VFACTIVE)
> >  			break;
> > -		} else {
> > +		else
> >  			msleep(I40EVF_RESET_WAIT_MS);
> > -		}
> >  	}
> >  	if (i == I40EVF_RESET_WAIT_COUNT) {
> >  		/* reset never finished */
> 
> Unnecessary else, maybe simpler as
> 
>  	for (i = 0; i < I40EVF_RESET_WAIT_COUNT; i++) {
> 		rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
> 			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
> 		if (rstat_val == I40E_VFR_VFACTIVE)
> 			break;
> 		msleep(I40EVF_RESET_WAIT_MS);
> 	}
> 

Thanks for your comments on these patches, Joe. I'm heading out for a three week vacation effective immediately, so I won't be getting to these comments right away. But "driver cleanup", including all of this stuff is on the top of my to-do list for when I get back.

-Mitch
