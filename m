From: Boaz Harrosh <openosd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Next branch: authgss: authgss.c: Fix warnings for uninitizlized
 variable expire
Date: Tue, 02 Sep 2014 16:59:45 +0300
Message-ID: <5405CD51.9020601@gmail.com>
References: <1409571154-50408-1-git-send-email-shakilk1729@gmail.com> <CAHQdGtQAwp_QuQE-xmjJNkcxbu7g4QtYQv8qrPT_qWpkym1GZg@mail.gmail.com> <5405A15F.2060002@gmail.com> <20140902132140.GA31793@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
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
To: Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140902132140.GA31793-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/02/2014 04:21 PM, Bruce Fields wrote:
> 
> You'd rather avoid sprinkling that all over, though.  If nothing else it
> increases the chances you'll suppress a legimate warning some day.
> 

But this is exactly why it was created.

If you do the "= 0" then it is gone forever. If you have missed a legitimate
needed assignment, it will be missed as well.

But if you do the uninitialized_var() dance then there is a make option that turns
it off and every once in a while people do a make with it to see if it still
holds.

The diff between foo = 0; and uninitialized_var(foo) is that the programmer is
communicating to his friends that:
	"I have encountered a bogus compiler, this is falsely initialized"

As opposed to =0 the compiler bug is covered up and forgotten

> And unless I'm missing something this one really does look like an
> unambiguous compiler bug.
> 

Right! so that is how you specify this in code at Linux: uninitialized_var(foo);

Putting =0 is way way worse, because it will never be revised and specially
not automatically with a make switch.

And leaving the warning on is even worse because two three of these and people
start to ignore warnings.

> --b.
> 

uninitialized_var was made to be a friend not an enemy, in the face of real
ugliness it is the best we can do. And that is what it should communicate to
everyone. Why has it become everyone's favorite blasphemy I do not know.

Cheers
Boaz

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
