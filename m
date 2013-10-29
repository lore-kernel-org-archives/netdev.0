From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 11/11] i40e: fix error return code in i40e_probe()
Date: Tue, 29 Oct 2013 16:02:31 -0700
Message-ID: <1383087751.12439.35.camel@joe-AO722>
References: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1383048151-15002-12-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1383066330.2713.20.camel@joe-AO722>
	 <20131029.185722.1940335622558600585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0018.hostedemail.com ([216.40.44.18]:51093 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751105Ab3J2XCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 19:02:35 -0400
In-Reply-To: <20131029.185722.1940335622558600585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-29 at 18:57 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> > On Tue, 2013-10-29 at 05:02 -0700, Jeff Kirsher wrote:
> >> Fix to return -ENOMEM in the memory alloc error handling
> >> case instead of 0, as done elsewhere in this function.
> > trivial note:
> >> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > []
> >> @@ -7204,8 +7204,10 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
> >>  	 */
> >>  	len = sizeof(struct i40e_vsi *) * pf->hw.func_caps.num_vsis;
> >>  	pf->vsi = kzalloc(len, GFP_KERNEL);
> >> -	if (!pf->vsi)
> >> +	if (!pf->vsi) {
> >> +		err = -ENOMEM;
> >>  		goto err_switch_setup;
> >> +	}
> > 
> > This might be better as:
> > 
> > 	pf->vsi = kcalloc(pf->hw.func_caps.num_vsis, struct i40e_vsi *),
> > 			  GFP_KERNEL);
> > 
> > and removing the now unused u32 len; declaration.
> 
> Agreed but that's a follow-on patch rather than something to block this
> pull request.

I don't think any trivial note should block anything
and if a submitter wants to update it later that's
just fine.
