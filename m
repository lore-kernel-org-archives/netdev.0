From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] can: add support for Janz VMOD-ICAN3 Intelligent
 CAN module
Date: Thu, 1 Apr 2010 13:03:59 -0700
Message-ID: <20100401130359.9a9b5c7b.akpm@linux-foundation.org>
References: <1269881932-3803-3-git-send-email-iws@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, sameo@linux.intel.com
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269881932-3803-3-git-send-email-iws@ovro.caltech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Mar 2010 09:58:51 -0700
"Ira W. Snyder" <iws@ovro.caltech.edu> wrote:

> The Janz VMOD-ICAN3 is a MODULbus daughterboard which fits onto any
> MODULbus carrier board. It is an intelligent CAN controller with a
> microcontroller and associated firmware.
> 

A neat-looking driver.

> ...
>
> +	spin_lock_irqsave(&mod->lock, flags);
>
> ...

It does this rather a lot.  it seems to be doing quite a lot of work
under that lock, too - quite a lot of memcpy_toio(), other stuff.

Is there potential here to disable interrupt for too long?  Not
possible to use spin_lock_bh() here?
