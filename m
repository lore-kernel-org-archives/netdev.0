From: Paul Mackerras <paulus@samba.org>
Subject: Re: [RFD][PATCH] Add JMEMCMP to Berkeley Packet Filters
Date: Sat, 12 Feb 2011 13:14:41 +1100
Message-ID: <20110212021441.GA3035@sammy.paulus.ozlabs.org>
References: <1297340087-10963-1-git-send-email-ian.molton@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rdunlap@xenotime.net, isdn@linux-pingi.de,
	arnd@arndb.de, davem@davemloft.net, herbert@gondor.apana.org.au,
	ebiederm@xmission.com
To: Ian Molton <ian.molton@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52075 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758202Ab1BLDMO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 22:12:14 -0500
Content-Disposition: inline
In-Reply-To: <1297340087-10963-1-git-send-email-ian.molton@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 10, 2011 at 12:14:46PM +0000, Ian Molton wrote:

> This patch implements an extension for BPF to allow filter programs to use a
> data section, along with a MEMCMP instruction.
> 
> There are a few issues noted in the patch itself, which can easily be
> addressed, and I would like to check wether sk_run_filter is ever expected to
> be called from a context that cannot sleep (I dont think it is).

The ppp driver (ppp_generic.c) calls sk_run_filter inside a region
protected by spin_lock_bh, so we can't sleep there.  Having sk_run_filter
potentially sleep would make it useless for ppp.

Paul.
