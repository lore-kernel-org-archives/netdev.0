From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 01/13] i40e: add checks for AQ error status bits
Date: Mon, 09 Jun 2014 14:02:05 -0700
Message-ID: <1402347725.3142.19.camel@joe-AO725>
References: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1402303758-1429-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5395B4C1.7070004@cogentembedded.com>
	 <1402346114.2183.5.camel@jtkirshe-mobl.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	davem@davemloft.net, Shannon Nelson <shannon.nelson@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0189.hostedemail.com ([216.40.44.189]:54188 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932609AbaFIVCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 17:02:09 -0400
In-Reply-To: <1402346114.2183.5.camel@jtkirshe-mobl.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-06-09 at 13:35 -0700, Jeff Kirsher wrote:
> On Mon, 2014-06-09 at 17:21 +0400, Sergei Shtylyov wrote:
> > On 06/09/2014 12:49 PM, Jeff Kirsher wrote:
> > > From: Shannon Nelson <shannon.nelson@intel.com>

> > > If the Firmware sets these bits, it will trigger an AdminQ
> > > interrupt to get the driver's attention to process the ARQ, which will
> > > likely be enough to clear the actual issue.
 
> >     Hm, why not dev_err() here and below?

> The thought was that these should be more of "FYI..." type of messages
> not "Oh Crap!..." messages.  So that is why dev_err() was not used,
> although we are not opposed to changing it if you feel it warrants it in
> a follow-up patch.
[]
> > > +	if (val & I40E_PF_ATQLEN_ATQCRIT_MASK) {
> > > +		dev_info(&pf->pdev->dev, "ASQ Critical Error detected\n");
> > > +		val &= ~I40E_PF_ATQLEN_ATQCRIT_MASK;
> > > +	}

I thought it was odd to have a "critical error"
emitted at KERN_INFO

Maybe adding something like
	"ARQ should fix this automatically"
would be enough.

Should any/all of these be ratelimited or maybe even
changed to dev_dbg?
