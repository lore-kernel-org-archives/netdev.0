From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Subject: Re: Backporting the Linux kernel, for good - was: Re: semantic patch
 inference
Date: Sat, 10 Sep 2011 05:12:51 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1109100512190.14019@ask.diku.dk>
References: <CAB=NE6U0ks9CobukO04=bZpnkm3Yw+Pf7keVPsP-hv1NyJZ_Xw@mail.gmail.com>
 <Pine.LNX.4.64.1109092245170.9242@ask.diku.dk>
 <CA+RMdsmEJRv8i81o_GD6o7Bn0MpQJMidghTnt3f-QEeU6V6eNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jesper Andersen <jespera-dAYI7NvHqcQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+RMdsmEJRv8i81o_GD6o7Bn0MpQJMidghTnt3f-QEeU6V6eNQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 10 Sep 2011, Jesper Andersen wrote:

> I'm in Singapore now and will head for Denmark tomorrow so I can't promise
> very instant reponses.
> 
> I haven't read the full thread just yet, but I just wanted to clarify one
> thing:
> 
> On Saturday, September 10, 2011, Julia Lawall wrote:
> >
> > There was also the question about one or multiple types of changes.  I
> > think this is not a problem, but Jesper should confirm.  If a patch
> > contains
> > two changes and one can be generalized and the other one cannot for some
> > reason, does spdiff give up on the whole thing, or does it do what it can?
> >
> >
> It's a little difficult to answer this precisely, so let me instead give an
> example and then you can say in what way my example falls short of what you
> thought of.
> 
> Suppose we have two functions that changed:
> 
> f1=
> void foo() {
>   bar(x->dev);
>   foz(117);
> }
> 
> f2=
> void goo() {
>   if(b) bar(y->dev);
> }
> 
> 
> And the new versions are:
> 
> f1'=
> void foo() {
>   bar(x);
>   foz(117, 42);
> }
> 
> f2'=
> void goo() {
>   if(b) bar(y);
> }
> 
> In this example there are basically three changes:
> 
> x->dev becomes x
> y->dev becomes y
> foz(117) becomes foz(117', 42)
> 
> In this case spdiff will find: (I just ran it to be sure)
> @@
> expression X0;
> @@
> - bar(X0->dev);
> + bar(X0);
> 
> So the one ungeneralizable change was simply not included. Does this cover
> your question Julia?

That seems good.  But perhaps the user would like to know about the 
elements that were not generalizable as well.

julia
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
