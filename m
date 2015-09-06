From: Eric Van Hensbergen <ericvh@gmail.com>
Subject: Re: [PATCH] 9p: trans_fd, initialize recv fcall properly if not set
Date: Sat, 5 Sep 2015 22:15:06 -0500
Message-ID: <CAFkjPT=1TAq5S_TBgKa_UyGs2CfhDKOWEqc9HyhKHw89vO_ZOQ@mail.gmail.com>
References: <1441273129-20185-1-git-send-email-dominique.martinet@cea.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: V9FS Developers <v9fs-developer@lists.sourceforge.net>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Dominique Martinet <dominique.martinet@cea.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:35585 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbbIFDP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 23:15:27 -0400
In-Reply-To: <1441273129-20185-1-git-send-email-dominique.martinet@cea.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 3, 2015 at 4:38 AM, Dominique Martinet
<dominique.martinet@cea.fr> wrote:
> That code really should never be called (rc is allocated in
> tag_alloc), but if it had been it couldn't have worked...
>
> Signed-off-by: Dominique Martinet <dominique.martinet@cea.fr>
> ---
>  net/9p/trans_fd.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> To be honest, I think it might be better to just bail out if we get in
> this switch (m->req->rc == NULL after p9_tag_lookup) and not try to
> allocate more, because if we get there it's likely a race condition and
> silently re-allocating will end up in more troubles than trying to
> recover is worth.
> Thoughts ?
>

Hmmm...trying to rattle my brain and remember why I put it in there
back in 2008.
It might have just been over-defensive programming -- or more likely it just
pre-dated all the zero copy infrastructure which pretty much guaranteed we had
an rc allocated and what is there is vestigial.  I'm happy to accept a
patch which
makes this an assert, or perhaps just resets the connection because something
has gone horribly wrong (similar to the ENOMEM path that is there now).

        -eric
