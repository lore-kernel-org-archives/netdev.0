From: Daniel Mack <daniel@caiaq.de>
Subject: Re: [PATCH] wireless: wext: allocate space for NULL-termination
 for 32byte SSIDs
Date: Wed, 16 Dec 2009 11:58:44 +0800
Message-ID: <20091216035844.GN28375@buzzloop.caiaq.de>
References: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
 <20091215.014308.77044043.davem@davemloft.net>
 <1260871411.3692.4.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	dcbw@redhat.com, m.hirsch@raumfeld.com, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org, stable@kernel.org,
	linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757627AbZLPD64@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1260871411.3692.4.camel@johannes.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 15, 2009 at 11:03:31AM +0100, Johannes Berg wrote:
> 
> > > -	/* kzalloc() ensures NULL-termination for essid_compat. */
> > > -	extra = kzalloc(extra_size, GFP_KERNEL);
> > > +	/* kzalloc() +1 ensures NULL-termination for essid_compat. */
> > > +	extra = kzalloc(extra_size + 1, GFP_KERNEL);
> 
> That doesn't seem correct.
> 
> If this is used in a SET, then it is purely an in-kernel thing and
> everything in the kernel is passed the length + data, and the kernel
> MUST NEVER treat the SSID as a NUL-terminated string.
> 
> If this is used in a GET, then it will be filled up to 32 bytes by the
> get handler, and the trailing \0 your patch reserves will never be
> copied into userspace.

The problem is the GET case. The libertas driver copies ssid_len
characters here and appends a trailing \0, which my patch caught now and
which caused memory corruption in before.

>From what I've seen, libertas _does_ treat the extra data correctly
at all places, I checked it several times now. (Btw, the %s format
string you pointed out all use print_ssid() to properly escape all
non-printable characters, so they're rules out, too).

I'll send a patch to fix the flaw in libertas.

Thanks,
Daniel
