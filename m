From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on
 low-end broads.
Date: Wed, 28 Dec 2011 10:17:10 -0800
Message-ID: <20111228101710.51c4893f@nehalam.linuxnetplumber.net>
References: <1325075319-13464-1-git-send-email-gurligebis@gentoo.org>
	<1325083051.2327.47.camel@deadeye>
	<CACPM=kWpGnBOuKPUK9MgzyETe4VmvEtVXkYtPA_+Xgn=COkCPw@mail.gmail.com>
	<1325092423.2327.70.camel@deadeye>
	<CACPM=kX2hcGt3XXDJkCAcOjv=5oqSHChhhphUAyRhR_PsNFEEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Roger Luethi <rl@hellgate.ch>
To: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48731 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754045Ab1L1SRN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 13:17:13 -0500
In-Reply-To: <CACPM=kX2hcGt3XXDJkCAcOjv=5oqSHChhhphUAyRhR_PsNFEEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like the hardware isn't really disabling interrupts correctly to support
NAPI. NAPI is supposed to be friendly and under load the work should move to
ksoftirqd. I suspect the IRQ management in this driver is borked.
There is some stupid spin loops in the IRQ handler that happen when looking for
Tx IRQ. I would run with debug set  and see if this is triggering.
