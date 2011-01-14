From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] r8169: keep firmware in memory.
Date: Fri, 14 Jan 2011 22:44:20 +0100
Message-ID: <201101142244.21117.rjw@sisk.pl>
References: <20110113230753.GA2750@electric-eye.fr.zoreil.com> <20110114163035.GY3702@decadent.org.uk> <AANLkTinumTQN3F=O_hC=jFTFLKVYyWmJNNvHx2A1jL2p@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <benh@debian.org>, Michael Tokarev <mjt@tls.msk.ru>,
	David Woodhouse <dwmw2@infradead.org>,
	Johannes Berg <johannes.berg@intel.com>,
	"Greg Kroah-Hartman" <gregkh@suse.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jarek =?utf-8?q?Kami=C5=84ski?= <jarek@vilo.eu.org>,
	Hayes <hayeswang@realtek.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:37593 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752091Ab1ANVoo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 16:44:44 -0500
In-Reply-To: <AANLkTinumTQN3F=O_hC=jFTFLKVYyWmJNNvHx2A1jL2p@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, January 14, 2011, Linus Torvalds wrote:
> On Fri, Jan 14, 2011 at 8:30 AM, Ben Hutchings <benh@debian.org> wrote:
> >
> > This is something I started to implement, but never got finished.  I
> > don't think it can be done without an API change, though, as we need
> > to know when to drop firmware from the cache.  But perhaps this could
> > be done with a hook in the device-driver binding code.
> 
> Or just associate the firmware with a module?
> 
> So if the firmware gets loaded, it stays in memory until the module is unloaded?
> 
> And this all would only be the case if CONFIG_PM is set, so you'd not
> waste memory unnecessarily.

Alternatively, a suspend/hibernate notifier can be used for that I think.

They are called before the freezing and after the thawing of user space, so the
the PM_POST_SUSPEND or PM_POST_RESTORE notification can easily cause the
firmare(s) to be dropped from memory.

Thanks,
Rafael
