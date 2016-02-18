From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/1] ser_gigaset: use container_of() instead of detour
Date: Thu, 18 Feb 2016 15:46:07 -0800
Message-ID: <20160218234607.GA4517@kroah.com>
References: <1455827348-8574-1-git-send-email-pebolle@tiscali.nl>
 <1455827348-8574-2-git-send-email-pebolle@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
	Martin Wilck <Martin.Wilck@ts.fujitsu.com>,
	Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
	Tilman Schmidt <tilman@imap.cc>, linux-kernel@vger.kernel.org,
	gigaset307x-common@lists.sourceforge.net
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:36766 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947614AbcBRXqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 18:46:08 -0500
Content-Disposition: inline
In-Reply-To: <1455827348-8574-2-git-send-email-pebolle@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2016 at 09:29:08PM +0100, Paul Bolle wrote:
> The purpose of gigaset_device_release() is to kfree() the struct
> ser_cardstate that contains our struct device. This is done via a bit of
> a detour. First we make our struct device's driver_data point to the
> container of our struct ser_cardstate (which is a struct cardstate). In
> gigaset_device_release() we then retrieve that driver_data again. And
> after that we finally kfree() the struct ser_cardstate that was saved in
> the struct cardstate.
> 
> All of this can be achieved much easier by using container_of() to get
> from our struct device to its container, struct ser_cardstate. Do so.
> 
> Note that at the time the detour was implemented commit b8b2c7d845d5
> ("base/platform: assert that dev_pm_domain callbacks are called
> unconditionally") had just entered the tree. That commit disconnected
> our platform_device and our platform_driver. These were reconnected
> again in v4.5-rc2 through commit 25cad69f21f5 ("base/platform: Fix
> platform drivers with no probe callback"). And one of the consequences
> of that fix was that it broke the detour via driver_data. That's because
> it made __device_release_driver() stop being a NOP for our struct device
> and actually do stuff again. One of the things it now does, is setting
> our driver_data to NULL. That, in turn, makes it impossible for
> gigaset_device_release() to get to our struct cardstate. Which has the
> net effect of leaking a struct ser_cardstate at every call of this
> driver's tty close() operation. So using container_of() has the
> additional benefit of actually working.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Tested-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
>  drivers/isdn/gigaset/ser-gigaset.c | 9 +--------
>  1 file changed, 1 insertion(+), 8 deletions(-)


<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
