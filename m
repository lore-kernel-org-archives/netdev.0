From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 2/4] e1000: add module option to set transmit descriptor size
Date: Fri, 27 Jun 2008 10:39:15 -0400
Message-ID: <20080627143915.GF32408@gospo.rdu.redhat.com>
References: <20080619211850.GD22981@gospo.rdu.redhat.com> <4864764D.6070802@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41147 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755081AbYF0OjV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 10:39:21 -0400
Content-Disposition: inline
In-Reply-To: <4864764D.6070802@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2008 at 01:10:37AM -0400, Jeff Garzik wrote:
> Andy Gospodarek wrote:
> >This patch added the TxDescPower parameter to the e1000 module.  This
> >parameter represents the size-order of each transmit descriptor.  The
> >valid size for descriptors would be 2^7 (128) - 2^12 (4096) bytes each.
> >As this value decreases one may want to consider increasing the
> >TxDescriptors value to maintain the same amount of frame memory.  This
> >patch does not change the defaults for any particular hardware model, so
> >this will not have an effect on existing users.
> >
> >The purpose of the patch is to address Tx Timeouts on 82545 and 82546
> >chips that can show up during high-stress situations.  Decreasing the
> >transmit descriptor size can shorten the amount of time that will be
> >spent DMAing frames to the hardware and can reduce the likely-hood that
> >Tx Timeouts will occur.
> >
> >Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> >---
> > drivers/net/e1000/e1000.h       |    6 ++++++
> > drivers/net/e1000/e1000_main.c  |   12 ++----------
> > drivers/net/e1000/e1000_param.c |   33 +++++++++++++++++++++++++++++++++++
> > 3 files changed, 41 insertions(+), 10 deletions(-)
> 
> I don't see why a module parameter is needed.  In practice, nobody will 
> ever think about this option, much less use it.
> 

Most users of 82545/6 chips that stress them heavily will probably think
about this option if we tell them how to use it and make it available.

While I agree it's not that useful for anyone else, if your option to
stop watchdog timeouts on your system is to set a module option and
reload or complain to Intel or your distro provider so they can send you
a custom driver with a hard-coded value which would you prefer?
