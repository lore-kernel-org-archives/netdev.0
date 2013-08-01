From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/4] USBNET: ax88179_178a: enable tso if host supports
 sg dma
Date: Thu, 01 Aug 2013 06:21:40 -0700
Message-ID: <1375363300.10515.135.camel@edumazet-glaptop>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	 <1375267909-30373-5-git-send-email-ming.lei@canonical.com>
	 <1375329066.10515.125.camel@edumazet-glaptop>
	 <CACVXFVNSZJ+ojjBCwYDKsWWvs03aL8BugcX7u483MvBCQCH1sg@mail.gmail.com>
	 <1375333461.10515.133.camel@edumazet-glaptop>
	 <CACVXFVMt-TgRVU+iA3NVuUzJSeXUPGvV89OnDdHaLEB1Ua6aAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVMt-TgRVU+iA3NVuUzJSeXUPGvV89OnDdHaLEB1Ua6aAw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-08-01 at 16:10 +0800, Ming Lei wrote:
> On Thu, Aug 1, 2013 at 1:04 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > On Thu, 2013-08-01 at 12:41 +0800, Ming Lei wrote:
> >
> >> From my trace result, lots of linear SKBs are cloned or header-cloned, so
> >> it needs skb copy too.
> >>
> >> Is it normal in xmit path to see cloned SKBs for driver? If not, I can add check
> >> to avoid allocation of 8 bytes header for non-cloned skb.
> >
> > Existing code is not very friendly and very complex.
> >
> > Sure TCP stack does a clone for every skb from socket write queue,
> > but header should be available for pushing 8 bytes.
> >
> > The !skb_cloned(skb) test should be removed if the memmove() is not
> > needed.
> >
> > Could you try following patch ?
> 
> Tested-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> This patch does work, and it will make the patch 4/4 become very
> simple, :-)
> 
> I will rewrite this one against your patch.

OK I'll post an official patch then. I presume you got performance
increase, since we no longer do a copy of the TCP packets.



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
