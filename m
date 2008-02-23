From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH 8/8] Jhash in too big for inlining, move under lib/
Date: Sat, 23 Feb 2008 12:05:36 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0802231006360.29504@kivilampi-30.cs.helsinki.fi>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-8-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-9-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20080223000214.81b1390a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-919503582-1203754103=:29504"
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59975 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753594AbYBWKFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 05:05:43 -0500
In-Reply-To: <20080223000214.81b1390a.akpm@linux-foundation.org>
Content-ID: <Pine.LNX.4.64.0802231141310.29504@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-919503582-1203754103=:29504
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0802231141311.29504@kivilampi-30.cs.helsinki.fi>

On Sat, 23 Feb 2008, Andrew Morton wrote:

> On Wed, 20 Feb 2008 15:47:18 +0200 "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > vmlinux.o:
> >  62 functions changed, 66 bytes added, 10935 bytes removed, diff: -10869
> > 
> > ...+ these to lib/jhash.o:
> >  jhash_3words: 112
> >  jhash2: 276
> >  jhash: 475
> > 
> > select for networking code might need a more fine-grained approach.
> 
> It should be possible to use a modular jhash.ko.  The things which you
> have identified as clients of the jhash library are usually loaded as modules.
> But in the case where someone does (say) NFSD=y we do need jhash.o linked into
> vmlinux also. This is doable in Kconfig but I always forget how.

Ok, even though its not that likely that one lives without e.g.
net/ipv4/inet_connection_sock.c or net/netlink/af_netlink.c? But maybe 
some guys "really know what they are doing" and can come up with config 
that would be able to build it as module (for other than proof-of-concept 
uses I mean)... :-/

> Adrian, Sam and Randy are the repositories of knowledge here ;)

Thanks, I'll consult them in this. I've never needed to do any Kconfig 
stuff so far so it's no surprise I have very little clue... :-)

I've one question for you Andrew, how would you like this kind of 
cross-subsys toucher to be merged, through you directly I suppose?


-- 
 i.
---696243703-919503582-1203754103=:29504--
