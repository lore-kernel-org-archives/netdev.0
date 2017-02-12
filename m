From: Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [RFC][PATCH] nfsd: add +1 to reference counting scheme for
 struct nfsd4_session
Date: Sat, 11 Feb 2017 20:15:21 -0500
Message-ID: <20170212011521.GD2768@fieldses.org>
References: <1486625901-10094-1-git-send-email-dwindsor@gmail.com>
 <CAEXv5_jUa8Av4JABoKSAueiLHSLzibMvaE-8DrVcxZHFceckMg@mail.gmail.com>
 <1486816302.4233.29.camel@poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "Reshetova, Elena" <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1486816302.4233.29.camel-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 11, 2017 at 07:31:42AM -0500, Jeff Layton wrote:
> The basic idea here is that nfsv4 sessions have a "resting state" of 0.
> We want to keep them around, but if they go "dead" then we we'll tear
> them down if they aren't actively in use at the time. So, we still free
> the thing when the refcount goes to zero, but we have an extra condition
> before we free it on the put -- that the session is also "dead" (meaning
> that the client asked us to destroy it).
> 
> Your patch doesn't look like it'll break anything, but I personally find
>  it harder to follow that way. The freeable reference state will be 1
> instead of the normal 0.

Alas, I don't have any examples in mind, but doesn't this pattern happen
all over?

You have objects that live in some data structure.  They're freed only
when they're removed from the data structure.  You want removal to fail
whenever they're in use.

So it's natural to use an atomic counter to track the number of external
users and some other lock to serialize lookup and destruction.

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
