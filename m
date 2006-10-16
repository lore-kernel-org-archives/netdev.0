From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/2] [PCI] Check that MWI bit really did get set
Date: Sun, 15 Oct 2006 17:31:34 -0700
Message-ID: <20061015173134.8a72bc2c.akpm@osdl.org>
References: <1160161519800-git-send-email-matthew@wil.cx>
	<200610151545.59477.david-b@pacbell.net>
	<20061015161834.f96a0761.akpm@osdl.org>
	<200610151716.36337.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, matthew@wil.cx,
	val_henson@linux.intel.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org,
	gregkh@suse.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161184AbWJPAbr@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
In-Reply-To: <200610151716.36337.david-b@pacbell.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 15 Oct 2006 17:16:35 -0700
David Brownell <david-b@pacbell.net> wrote:

> 
> > You, the driver author _do not know_ what pci_set_mwi() does at present, on
> > all platforms, nor do you know what it does in the future. 
> 
> I know that it enables MWI accesses ... or fails.  Beyond that, there
> should be no reason to care.  If the hardware can use a lower-overhead
> type of PCI bus cycle, I want it to do so.  If not, no sweat.
> 

There are two reasons why it can fail:

1: The bus doesn't support MWI.  Here, the caller doesn't care.

2: The bus _does_ support MWI, but the attempt to enable it failed. 
   Here we very much do care, because we're losing performance.

> 
> > This is not a terribly important issue, and it is far from the worst case
> > of missed error-checking which we have in there. 
> 
> The reason I think it's important enough to continue this discussion is
> that as it currently stands, it's a good example of a **BAD** interface
> design ... since it's pointlessly marked as must_check.  (See appended
> patch to fix that issue.)

It's important to continue this discussion so that certain principles can
be set and agreed to.  Because we have a *lot* of unchecked errors in
there.  We would benefit from setting guidelines establishing

- Which sorts of errors should be handled in callers

- Which sorts of errors should be handled (ie: just reported) in callees

- Which sorts of errors should be handled in neither callers nor callees
  (are there any of these?)

- Whether is it ever legitimate for a caller to not check the return code
  from a callee which can return -EFOO.  (I suspect not - it probably
  indicates a misdesign in the callee, as in this case).
