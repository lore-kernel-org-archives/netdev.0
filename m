From: Sowmini Varadhan <sowmini.varadhan-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: net/rds: use-after-free in inet_create
Date: Tue, 28 Feb 2017 12:33:28 -0500
Message-ID: <20170228173328.GL31155@oracle.com>
References: <CACT4Y+bi=rZr9yrajA0o0iUeR4N0q-sXYudBVsOeOiHbuApBeA@mail.gmail.com>
 <20170228153737.GG31155@oracle.com>
 <CACT4Y+aobp+g_AYoX6j1eftyyirK4pBxhOXz9hDu+XU+-jxSYw@mail.gmail.com>
 <20170228161544.GH31155@oracle.com>
 <CACT4Y+bWWAiMYQN_Fvxs7CKR9hRAA+r0t_YZhja3B5xGcZ4vcQ@mail.gmail.com>
 <20170228163833.GI31155@oracle.com>
 <CACT4Y+Y5eM8hKQ7BgA4hEN7ozkhRGgvGJRU6Smrths6noC-PMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        syzkaller <syzkaller-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+Y5eM8hKQ7BgA4hEN7ozkhRGgvGJRU6Smrths6noC-PMw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On (02/28/17 17:51), Dmitry Vyukov wrote:
> Searching other crashes for "net/rds" I found 2 more crashes that may
> be related. They suggest that the delayed works are not properly
> stopped when the socket is destroyed. That would explain how
> rds_connect_worker accesses freed net, right?

yes, I think we may want to explicitly cancel this workq.. this
in rds_conn_destroy().

I'm trying to build/sanity-test (if lucky, reproduce the bug)
as I send this out.. let me get back to you..

If I have a patch against net-next, would you be willing/able to 
try it out? given that this does not show up on demand, I'm not
sure how we can check that "the fix worked"..

--Sowmini
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
