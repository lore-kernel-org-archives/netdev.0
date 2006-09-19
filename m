From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 03/23] e100: Add debugging code for cb cleaning and csum
 failures.
Date: Tue, 19 Sep 2006 17:40:34 -0400
Message-ID: <451063D2.7020301@pobox.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172838.4605.35958.stgit@gitlost.site> <20060919213336.GA29362@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:10178 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750879AbWISVkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 17:40:40 -0400
To: Dave Jones <davej@redhat.com>
In-Reply-To: <20060919213336.GA29362@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Jones wrote:
> On Tue, Sep 19, 2006 at 10:28:38AM -0700, Kok, Auke wrote:
>  > 
>  > Refine cb cleaning debug printout and print out all cleaned cbs' status. Add
>  > debug flag for EEPROM csum failures that were overridden by the user.
>  > 
>  > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>  > Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>  > ---
>  > 
>  >  drivers/net/e100.c |    9 ++++++---
>  >  1 files changed, 6 insertions(+), 3 deletions(-)
>  > 
>  > diff --git a/drivers/net/e100.c b/drivers/net/e100.c
>  > index ab0868c..ae93c62 100644
>  > --- a/drivers/net/e100.c
>  > +++ b/drivers/net/e100.c
>  > @@ -761,6 +761,8 @@ static int e100_eeprom_load(struct nic *
>  >  		DPRINTK(PROBE, ERR, "EEPROM corrupted\n");
>  >  		if (!eeprom_bad_csum_allow)
>  >  			return -EAGAIN;
>  > +		else
>  > +			add_taint(TAINT_MACHINE_CHECK);
> 
> I object to this flag being abused this way.
> A corrupt EEPROM on a network card has _nothing_ to do with
> a CPU machine check exception.

Fair enough.  Better suggestions?

I think it's fair to set _some_ taint flag, perhaps a new one, on a 
known corrupted firmware.  But if others disagree, I'll follow the 
consensus here.

	Jeff, not having a strong opinion in this case



