From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC] breakage in sysfs_readdir() and s_instances abuse in sysfs
Date: Sun, 12 Jun 2011 10:59:42 -0700
Message-ID: <BANLkTi=AfYH1eg_O1N2M9BfcF=UmBFPy6w@mail.gmail.com>
References: <20110604001518.GT11521@ZenIV.linux.org.uk> <m1k4cy6auf.fsf@fess.ebiederm.org>
 <20110607215834.GR11521@ZenIV.linux.org.uk> <20110607225902.GS11521@ZenIV.linux.org.uk>
 <20110609012646.GV11521@ZenIV.linux.org.uk> <m1y617wmeb.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <m1y617wmeb.fsf@fess.ebiederm.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 12, 2011 at 12:15 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> I honestly hate the pattern that is being used here. =A0Holding a
> reference count because we can't be bothered to free things reliably
> when we actually stop using them.

WHAT?

That's what a reference count *is*. It's all about "free things
reliably when we actually stop using them".

Your comment makes zero sense.

EVERY SINGLE kernel data structure should be reference counted. Read
Documentation/CodingStyle, or look at any of the good code in the
kernel (ie core process or VFS code). A non-refcounted data structure
that is used by more than one entity IS A BUG!

Quite frankly, your objection sounds moronic. If there is more than
one user, then a reference count is _always_ the right thing. Nothing
else ever works, and trust me, people have tried. They've tried
locking, they've tried luck, they've tried crazy things. Nothing but
refcounts works.

                           Linus
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
