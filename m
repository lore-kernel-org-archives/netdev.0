From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [TG3]: Workaround MSI bug on 5714/5780.
Date: Thu, 6 Sep 2007 09:45:16 -0400
Message-ID: <20070906134508.GA10317@gospo.rdu.redhat.com>
References: <1189022828.4960.2.camel@dell> <20070906.040235.71121480.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: David Miller <davem@davemloft.net>, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752427AbXIFNpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 09:45:19 -0400
Content-Disposition: inline
In-Reply-To: <20070906.040235.71121480.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 06, 2007 at 04:02:35AM -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Wed, 05 Sep 2007 13:07:08 -0700
> 
> > [TG3]: Workaround MSI bug on 5714/5780.
> > 
> > A hardware bug was revealed after a recent PCI MSI patch was made to
> > always disable legacy INTX when enabling MSI.  The 5714/5780 chips
> > will not generate MSI when INTX is disabled, causing MSI failure
> > messages to be reported, and another patch was made to workaround the
> > problem by disabling MSI on ServerWorks HT1000 bridge chips commonly
> > found with the 5714.
> > 
> > We workaround this chip bug by enabling INTX after we enable MSI and
> > after we resume from suspend.
> > 
> > Update version to 3.81.
> > 
> > This problem was discovered by David Miller.
> > 
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Thanks a lot Michael, I'll apply this and work on reverting that
> incorrect MSI chipset quirk too.

Michael,

Is is really necessary to get rid of the HT1000 patch?

commit e3008dedff4bdc96a5f67224cd3d8d12237082a0
Author: Andy Gospodarek <andy@greyhouse.net>
Date:   Thu May 10 22:58:57 2007 -0700

    PCI: disable MSI by default on systems with Serverworks HT1000 chips

This patch was designed to address tg3 and bnx2 messages printed on
systems with HT1000 chips IIRC.  Are we going back to those messages on
bnx2 or is there a workaround in that driver needed too?

-andy

