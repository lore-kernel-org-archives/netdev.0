From: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH] nfsd: add +1 to reference counting scheme for struct nfsd4_session
Date: Mon, 13 Feb 2017 06:42:56 -0500
Message-ID: <CAEXv5_g=DS4wk0mgZuw-doVCqountb-CxZki1LOoQH-P7W1U4A@mail.gmail.com>
References: <1486625901-10094-1-git-send-email-dwindsor@gmail.com>
 <CAEXv5_jUa8Av4JABoKSAueiLHSLzibMvaE-8DrVcxZHFceckMg@mail.gmail.com>
 <1486816302.4233.29.camel@poochiereds.net> <CAEXv5_gd7F-eaazzU1BWPzH4huhEcO1Y-FWov5UP9T+6R+fv-A@mail.gmail.com>
 <20170213103815.GA5131@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org,
        Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "Reshetova, Elena" <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170213103815.GA5131-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 13, 2017 at 5:38 AM, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org> wrote:
> On Sat, Feb 11, 2017 at 09:01:15AM -0500, David Windsor wrote:
>> I'm not sure there's another way to accomplish what we need
>> (initializing struct nfsd4_session objects with refcount=1) without
>> also modifying the freeable reference state.  After migrating to the
>> refcount_t API, if we leave init_session() as is, the first call to
>> nfsd4_get_session_locked() will fail:
>
> Which is a pretty clear indicator that this code should simply not
> migrate to the recount_t API.  Why was it even considered if the
> conversion is obviously broken?

I'm not sure this is a sound argument for not converting to
refcount_t.  In other locations in which refcounting schemes are
"unnatural," i.e. freeing refcounted objects when their refcount is -1
(rather than 0), conversion to refcount_t is accomplished by
performing a logical +1 to the overall refcounting scheme.  We're
auditing all refcounting corner cases, such as these, to see if
similar solutions can be found.

Thanks,
David
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
