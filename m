From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [RFC][PATCH] nfsd: add +1 to reference counting scheme for
 struct nfsd4_session
Date: Mon, 13 Feb 2017 02:38:15 -0800
Message-ID: <20170213103815.GA5131@infradead.org>
References: <1486625901-10094-1-git-send-email-dwindsor@gmail.com>
 <CAEXv5_jUa8Av4JABoKSAueiLHSLzibMvaE-8DrVcxZHFceckMg@mail.gmail.com>
 <1486816302.4233.29.camel@poochiereds.net>
 <CAEXv5_gd7F-eaazzU1BWPzH4huhEcO1Y-FWov5UP9T+6R+fv-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org,
        Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "Reshetova, Elena" <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAEXv5_gd7F-eaazzU1BWPzH4huhEcO1Y-FWov5UP9T+6R+fv-A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 11, 2017 at 09:01:15AM -0500, David Windsor wrote:
> I'm not sure there's another way to accomplish what we need
> (initializing struct nfsd4_session objects with refcount=1) without
> also modifying the freeable reference state.  After migrating to the
> refcount_t API, if we leave init_session() as is, the first call to
> nfsd4_get_session_locked() will fail:

Which is a pretty clear indicator that this code should simply not
migrate to the recount_t API.  Why was it even considered if the
conversion is obviously broken?
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
