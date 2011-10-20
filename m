From: "bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [RFC PATCH 0/5] SUNRPC: "RPC pipefs per network namespace"
 preparations
Date: Thu, 20 Oct 2011 08:32:42 -0400
Message-ID: <20111020123242.GN5444@fieldses.org>
References: <20111017120629.4541.67395.stgit@localhost6.localdomain6>
 <4EA000C6.1040502@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4EA000C6.1040502-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 20, 2011 at 03:06:46PM +0400, Stanislav Kinsbursky wrote:
> Guys, please, spend some of your expensive time to review this patch-set briefly.

I'll try to take a look soon, but I'm travelling tomorrow through the
31st, and things will be a little hectic.

Just one quick comment:

> >The only problem about I'm not sure how to solve properly yet, is auth gss
> >pipes creations operations. Hoping for some help with it.

I suspect one reason it may be a little complicated is the
upcall-version switching.  The old version is deprecated, and there's no
need to support the combination of the old version with the a new
feature like containers.  And now that it's been there a while the
version-switching code already achieved its goal of avoiding a flag day.
So, one approach might be:

	- move all the code for the old gss upcall and for the version
	  switching under a new CONFIG_DEPRECATED_GSS, or similar.
	- print a warning if the old stuff is used, and plan to rip it
	  out completely in a future kernel version.
	- do something that works just in the !CONFIG_DEPRECATED_GSS
	  case.

Would that help?

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
