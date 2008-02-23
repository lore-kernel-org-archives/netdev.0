From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/8]: uninline & uninline
Date: Sat, 23 Feb 2008 10:55:17 -0800
Message-ID: <20080223105517.4d706511.akpm@linux-foundation.org>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20080223000220.e9229c99.akpm@linux-foundation.org>
	<p734pbz95lx.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ilpo =?ISO-8859-1?B?SuRydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:44362 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754372AbYBWS4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 13:56:40 -0500
In-Reply-To: <p734pbz95lx.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Feb 2008 14:15:06 +0100 Andi Kleen <andi@firstfloor.org> wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> 
> >> -41525  2066 f, 3370 +, 44895 -, diff: -41525  IS_ERR 
> >
> > This is a surprise.  I expect that the -mm-only
> > profile-likely-unlikely-macros.patch is the cause of this and mainline
> > doesn't have this problem.
> 
> Shouldn't they only have overhead when the respective CONFIG is enabled?

yup.

> > If true, then this likely/unlikely bloat has probably spread into a lot of
> > your other results and it all should be redone against mainline, sorry :(
> >
> > (I'm not aware of anyone having used profile-likely-unlikely-macros.patch
> > in quite some time.  That's unfortunate because it has turned up some
> > fairly flagrant code deoptimisations)
> 
> Is there any reason they couldn't just be merged to mainline? 
> 
> I think it's a useful facility.

ummm, now why did we made that decision...  I think we decided that it's
the sort of thing which one person can run once per few months and that
will deliver its full value.  I can maintain it in -mm and we're happy - no
need to add it to mainline.  No strong feelings either way really.

It does have the downside that the kernel explodes if someone adds unlikely
or likely to the vdso code and I need to occasionally hunt down new
additions and revert them in that patch.  That makes it a bit of a
maintenance burden.

