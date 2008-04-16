From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH][netlabel] Don't risk NULL ptr deref in netlbl_unlabel_staticlist_gen() if ifindex not found
Date: Wed, 16 Apr 2008 23:30:10 +0200
Message-ID: <9a8748490804161430w3a9a9ed8o4dcc80d260a14500@mail.gmail.com>
References: <alpine.LNX.1.00.0804162304220.9837@dragon.funnycrock.com>
	 <200804161721.33749.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David Miller" <davem@davemloft.net>
To: "Paul Moore" <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:52958 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816AbYDPVaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 17:30:23 -0400
Received: by yw-out-2324.google.com with SMTP id 5so1425100ywb.1
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 14:30:11 -0700 (PDT)
In-Reply-To: <200804161721.33749.paul.moore@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/04/2008, Paul Moore <paul.moore@hp.com> wrote:
> On Wednesday 16 April 2008 5:08:58 pm Jesper Juhl wrote:
>  > Hi,
>  >
>  > dev_get_by_index() may return NULL if nothing is found. In
>  > net/netlabel/netlabel_unlabeled.c::netlbl_unlabel_staticlist_gen()
>  > the function is called, but the return value is never checked. If it
>  > returns NULL then we'll deref a NULL pointer on the very next line.
>  > I checked the callers, and I don't think this can actually happen
>  > today, but code changes over time and in the future it might happen
>  > and it does no harm to be defensive and check for the failure, so
>  > that if/when it happens we'll fail gracefully instead of crashing.
>  >
>  > Please consider the patch below for inclusion.
>  >
>  >
>  > Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
>
>
> I agree we should check for NULL here.  I checked the return of
>  dev_get_by_index() in the rest of the file I must have just forgotten
>  to check it here.
>
>  Thanks for finding this and fixing it.
>
You're welcome.

>  Acked-by: Paul Moore <paul.moore@hp.com>
>

David, will you merge this in the net tree ?

>
>  >
>  >  netlabel_unlabeled.c |    4 ++++
>  >  1 file changed, 4 insertions(+)
>  >
>  > diff --git a/net/netlabel/netlabel_unlabeled.c
>  > b/net/netlabel/netlabel_unlabeled.c index 4478f2f..6af9457 100644
>  > --- a/net/netlabel/netlabel_unlabeled.c
>  > +++ b/net/netlabel/netlabel_unlabeled.c
>  > @@ -1339,6 +1339,10 @@ static int netlbl_unlabel_staticlist_gen(u32
>  > cmd,
>  >
>  >       if (iface->ifindex > 0) {
>  >               dev = dev_get_by_index(&init_net, iface->ifindex);
>  > +             if (!dev) {
>  > +                     ret_val = -ENODEV;
>  > +                     goto list_cb_failure;
>  > +             }
>  >               ret_val = nla_put_string(cb_arg->skb,
>  >                                        NLBL_UNLABEL_A_IFACE, dev->name);
>  >               dev_put(dev);
>

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
