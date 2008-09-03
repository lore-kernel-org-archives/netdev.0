From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH] e1000e: avoid duplicated output of device name in kernel warning
Date: Wed, 3 Sep 2008 16:43:42 +0200
Message-ID: <200809031643.43642.elendil@planet.nl>
References: <20080829000100.5149.26290.stgit@jtkirshe-mobile.jf.intel.com> <48BE9ABA.3030304@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hpsmtp-eml11.kpnxchange.com ([213.75.38.111]:40349 "EHLO
	hpsmtp-eml11.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752010AbYICOns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 10:43:48 -0400
In-Reply-To: <48BE9ABA.3030304@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 03 September 2008, Jeff Garzik wrote:
> Jeff Kirsher wrote:
> > From: Frans Pop <elendil@planet.nl>
> >
> > With 2.6.27-rc3 I noticed the following messages in my boot log:
> >
> > 0000:01:00.0: 0000:01:00.0: Warning: detected DSPD enabled in EEPROM
> > 0000:01:00.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:16:76:04:ff:09
> >
> > The second seems correct, but the first has a silly repetition of the
> > PCI device before the actual message. The message originates from
> > e1000_eeprom_checks in e1000e/netdev.c.
> >
> > With this patch below the first message becomes
> >
> >   e1000e 0000:01:00.0: Warning: detected DSPD enabled in EEPROM
> >
> > which makes it similar to directly preceding messages.
> >
> > Use dev_warn instead of e_warn in e1000_eeprom_checks() as the
> > interface name has not yet been assigned at that point.
> >
> > Signed-off-by: Frans Pop <elendil@planet.nl>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >
> >  drivers/net/e1000e/netdev.c |    6 ++++--
> >  1 files changed, 4 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/net/e1000e/netdev.c
> > b/drivers/net/e1000e/netdev.c index d266510..4563f34 100644
> > --- a/drivers/net/e1000e/netdev.c
> > +++ b/drivers/net/e1000e/netdev.c
> > @@ -4335,13 +4335,15 @@ static void e1000_eeprom_checks(struct
> > e1000_adapter *adapter) ret_val = e1000_read_nvm(hw,
> > NVM_INIT_CONTROL2_REG, 1, &buf); if (!(le16_to_cpu(buf) & (1 << 0)))
> > {
> >  		/* Deep Smart Power Down (DSPD) */
> > -		e_warn("Warning: detected DSPD enabled in EEPROM\n");
> > +		dev_warn(&adapter->pdev-dev,
> > +		         "Warning: detected DSPD enabled in EEPROM\n");
>
> breaks build, should be "pdev->dev"

It was correct in the original patch I submitted and IIRC Andrew already 
noticed that error and added a "fixup" patch in his tree.

Cheers.
FJP
