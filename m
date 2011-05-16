From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: several packets in a single buffer in Rx
Date: Mon, 16 May 2011 21:15:12 +0100
Message-ID: <1305576912.2885.32.camel@bwh-desktop>
References: <BANLkTimkgtQL1A2A3iAP-UYK2KdDvPmY3Q@mail.gmail.com>
	 <BANLkTinb3kaK7_b=47AL+Mb6Zmt9twEM9g@mail.gmail.com>
	 <BANLkTi=aBLPX7OMKi=sMhT81x-2f6Ci6sQ@mail.gmail.com>
	 <BANLkTi=xJbL-26Hzg0Pp5zKPUi35bV6VmA@mail.gmail.com>
	 <BANLkTin_stn+7Ja3hbuaOgtrEVJEoT9Lhw@mail.gmail.com>
	 <BANLkTimvCVcQX-7teQgG7EQV9eeLgG3JnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Guy, Wey-Yi" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, guy.cohen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTimvCVcQX-7teQgG7EQV9eeLgG3JnQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-05-16 at 23:04 +0300, Tomas Winkler wrote:
> 2011/5/16 Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> > 2011/5/16 Micha=C5=82 Miros=C5=82aw <mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> >> W dniu 16 maja 2011 14:59 u=C5=BCytkownik Emmanuel Grumbach
> >> <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> napisa=C5=82:
> >>> 2011/5/16 Micha=C5=82 Miros=C5=82aw <mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> >>>> 2011/5/16 Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> >>>>> I would like to be able to deliver the same page several times =
to the
> >>>>> stack without having the stack consume it before the last time =
I
> >>>>> deliver it.
> >>>>> Of course I would like to avoid cloning it.
> >>>>
> >>>> Just do get_page() on the page having another packet in it befor=
e
> >>>> passing skb up.
> >>>>
> >>>
> >>> I can see the path:
> >>> __kfree_skb -> skb_release_all -> skb_release_data -> put_page
> >>> put_page will free the page iff the _count variable reaches 0. Of=
 course,
> >>> _count is incremented by get_page.
> >>>
> >>> I will give it try.
> >>>
> >>> I understand that this will work regardless the order given to
> >>> alloc_pages right ?
> >>
> >> Yes. Remember that if you put a lot of packets in a big-order page
> >> then the memory will be freed only after all packets are freed.
> >
> > Sure. Thanks for the help.
>=20
> How it is ensured that skb manipulation won't corrupt another packet
> on the same page?

=46ragments attached to an skb are always treated as read-only.  The
headers will be copied into the skb's header buffer and may be modified
there.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
