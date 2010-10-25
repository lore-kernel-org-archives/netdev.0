From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] TIPC security issues
Date: Sun, 24 Oct 2010 20:42:39 -0700
Message-ID: <AANLkTinXmKrf+wovco0j_aBuB7=qSq42+bVCM-amfL7W@mail.gmail.com>
References: <1287704752.11051.79.camel@Dan> <AANLkTi=V93A660+YS8C2TvC13kGUcJpFgjPHUvONd_WW@mail.gmail.com>
 <20101024.191415.226787411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: drosenberg@vsecurity.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, netdev@vger.kernel.org,
	security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41810 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752836Ab0JYDnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 23:43:02 -0400
Received: from mail-iw0-f174.google.com (mail-iw0-f174.google.com [209.85.214.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o9P3h1oK027984
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Sun, 24 Oct 2010 20:43:01 -0700
Received: by iwn10 with SMTP id 10so238439iwn.19
        for <netdev@vger.kernel.org>; Sun, 24 Oct 2010 20:43:00 -0700 (PDT)
In-Reply-To: <20101024.191415.226787411.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 24, 2010 at 7:14 PM, David Miller <davem@davemloft.net> wrote:
>
> Maybe the filesystem paths are this way, but the bulk of the socket
> paths properly use size_t when touching anything even related
> to an I/O length.

Umm. "Bulk" is not "all".

Which is the whole point. Most filesystems have no trouble either. But
when a mistake is a security issue, that's not enough.

> I know that TCP can do a >= 4GB write just fine right now.

Again - totally irrelevant. Plus anybody who relies on doing 4GB
writes in one go would be broken _anyway_.

In other words, what you argue for has zero upsides, and it has
downsides. As shown by the fact that TIPC was buggy.

> In fact if you look I recently removed the last obstacle to this based
> upon a bug report from a user trying to do a 4GB write (which ended up
> getting truncated to zero):

.. and if you looked at my suggested patch, you would have seen that
it would have avoided that, and still worked fine (exactly because it
doesn't truncate anything).

David - the issue is _security_. The way to fix security problems is
not to say "most things handle this correctly". The way to avoid them
is to have several layers of handling things correctly, so that even
when one turns out to be broken, the others still protect it.

                        Linus
