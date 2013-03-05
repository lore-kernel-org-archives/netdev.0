From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH 0/7] USB: don't recover device if suspend fails in system sleep
Date: Tue, 05 Mar 2013 14:28:32 +0100
Message-ID: <2867446.m8zodPstBd@linux-5eaq.site>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com> <3703451.5FViJ58GpZ@linux-5eaq.site> <CACVXFVMkztqc_K+8gvPJhU-rC+c_STDyZLDmJZ2p1hLnADDXvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38989 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753547Ab3CEN2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Mar 2013 08:28:18 -0500
In-Reply-To: <CACVXFVMkztqc_K+8gvPJhU-rC+c_STDyZLDmJZ2p1hLnADDXvg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 05 March 2013 21:08:09 Ming Lei wrote:
> On Tue, Mar 5, 2013 at 8:50 PM, Oliver Neukum <oneukum@suse.de> wrote:

> > In other words, if we don't handle errors, there must be no errors,
> > otherwise it doesn't matter what we do in the error case. We'd leave
> > the problem to generic layers.
> 
> Generic layers can't handle the driver's specific failure.

We depend on stopping the HC forcing all devices into suspend.
We know this is problematic. For example some disk enclosures
need to flush cache. Fortunately for us this is done in the SCSI
layer.

> If driver records its suspend failure state in suspend(), resume()
> should and can deal with it without much difficulty.

Yes, but why bother? Either we can safely suspend in any state or
we must not ignore errors.

> > Furthermore there is a small chance that although the device tree
> > is walked, teh system suspend fails for another later reason that
> > is not ignored. In that case the drivers need to do error recovery,
> > albeit in resume().
> 
> Yes,  resume() need to handle the USB system suspend failure
> either in normal resume or error recovery, both are basically same.

In theory yes, in practice usually power is cut.

	Regards
		Oliver
