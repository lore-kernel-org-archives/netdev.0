From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v2 04/15] i40e: remove BUG_ON from feature string
 building
Date: Wed, 25 Nov 2015 11:36:34 -0800
Message-ID: <1448480194.20113.48.camel@perches.com>
References: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448475679-57194-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5655FD72.70902@cogentembedded.com> <1448476535.3021.5.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	John Ronciak <john.ronciak@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0222.hostedemail.com ([216.40.44.222]:34966 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752159AbbKYTgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 14:36:38 -0500
In-Reply-To: <1448476535.3021.5.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-25 at 10:35 -0800, Jeff Kirsher wrote:
> On Wed, 2015-11-25 at 21:26 +0300, Sergei Shtylyov wrote:
> > On 11/25/2015 09:21 PM, Jeff Kirsher wrote:
> > 
> > > From: Shannon Nelson <shannon.nelson@intel.com>
> > > 
> > > There's really no reason to kill the kernel thread just because of a
> > > little info string. This reworks the code to use snprintf's limiting to
> > > assure that the string is never too long, and WARN_ON to still put out
> > > a warning that we might want to look at the feature list length.
> > > 
> > > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
[]
> > >        if (pf->flags & I40E_FLAG_VEB_MODE_ENABLED)
> > > -             buf += sprintf(buf, "VEB ");
> > > +             i += snprintf(&buf[i], REMAIN(i), "VEPA ");
> > 
> >     Not "VEB "?
> 
> Nice catch Sergei, I will wait a till this afternoon to respin the
> patch series, just in case there are other changes needed that our
> validation did not catch. :-)

trivia:

If you redo these, it'd be nicer not to use " " after each
fixed string, but use " " before each fixed string.

The final output string would be 1 byte shorter overall and
not have an excess " " before the newline.

The declaration of i doesn't need initialization to 0:

	i = snprintf(buf, INFO_STRING_LEN, "Features: PF-id[%d]", ...

would work.
