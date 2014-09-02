From: Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] Next branch: authgss: authgss.c: Fix warnings for
 uninitizlized variable expire
Date: Tue, 2 Sep 2014 10:17:39 -0400
Message-ID: <20140902141739.GB31793@fieldses.org>
References: <1409571154-50408-1-git-send-email-shakilk1729@gmail.com>
 <CAHQdGtQAwp_QuQE-xmjJNkcxbu7g4QtYQv8qrPT_qWpkym1GZg@mail.gmail.com>
 <5405A15F.2060002@gmail.com>
 <20140902132140.GA31793@fieldses.org>
 <5405CD51.9020601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Shakil A Khan <shakilk1729-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel mailing list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Paul McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	William Andros Adamson <andros-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Jeffrey Layton <jlayton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Boaz Harrosh <openosd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5405CD51.9020601-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 02, 2014 at 04:59:45PM +0300, Boaz Harrosh wrote:
> uninitialized_var was made to be a friend not an enemy, in the face of real
> ugliness it is the best we can do. And that is what it should communicate to
> everyone. Why has it become everyone's favorite blasphemy I do not know.

Not personally claiming it should never be used, just that this
particular case is kind of extreme, since unless I'm missing a real
compilication it's basically just:

	if (ctx)
		assign to expire
	...
	if (ctx)
		use expire

A compiler wouldn't have to be that smart to actually prove to itself
that expire is initialized at the last step, and that it's not only
failing to do that but actually flagging it as possibly unitialized is
weird.

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
