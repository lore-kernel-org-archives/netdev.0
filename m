From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: [PATCH v4] usbnet/cdc_ncm: Don't use stack variables for DMA
Date: Fri, 12 Aug 2011 11:07:16 -0400
Message-ID: <20110812150715.GD3014@zod.bos.redhat.com>
References: <20110808123406.GA2526@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@suse.de, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>,
	Alexey ORISHKO <alexey.orishko@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51112 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751093Ab1HLPH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 11:07:26 -0400
Content-Disposition: inline
In-Reply-To: <20110808123406.GA2526@zod.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 08, 2011 at 08:34:06AM -0400, Josh Boyer wrote:
> The cdc_ncm driver still has a few places where stack variables are
> passed to the cdc_ncm_do_request function.  This triggers a stack trace in
> lib/dma-debug.c if the CONFIG_DEBUG_DMA_API option is set.
> 
> Adjust these calls to pass parameters that have been allocated with
> kzalloc.
> 
> Signed-off-by: Josh Boyer <jwboyer@redhat.com>
> ---
> v4: Rebase against 3.1-rc1
> v3: Fix checkpatch errors
> v2: Fix leak in error path
> 
>  drivers/net/usb/cdc_ncm.c |   47 ++++++++++++++++++++++++++++++++++++--------
>  1 files changed, 38 insertions(+), 9 deletions(-)

Just curious, but which tree would this be pulled into?  usb or net or?

josh
