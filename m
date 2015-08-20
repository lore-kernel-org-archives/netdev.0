From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: Exporting obscene amounts of data in rtnl_link_ops->fill_info()
Date: Wed, 19 Aug 2015 22:59:19 -0700
Message-ID: <CAE4R7bDhn02qVsn3fja16uz3wOXycZHfXHYynOOdWGJzY2UOhQ@mail.gmail.com>
References: <CAHmME9pps6BJwubBNgp294JKGkGXHUyb1kMdTGCEwok__aQjmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9pps6BJwubBNgp294JKGkGXHUyb1kMdTGCEwok__aQjmw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 19, 2015 at 5:47 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> Hi guys,
>
> I have a new link driver that registers a rtnl_link_ops. For many
> things, the rtnl interfaces are perfectly suited: I can use netlink in
> userspace to check out packet counts, adjust interface parameters, and
> all sorts of things. There is even the "fill_info" function exporting
> interface-specific types of data to userspace through the standard
> netlink interfaces. I'm glad this is here, because it's exactly what I
> want.
>
> Problem: sometimes I want to export a *lot* of data to userspace. When
> this happens, even if I make the netlink socket receive buffer really
> huge, this code path is still reached in rtnetlink.c:
>
>                         err = rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
>                                                NETLINK_CB(cb->skb).portid,
>                                                cb->nlh->nlmsg_seq, 0,
>                                                NLM_F_MULTI,
>                                                ext_filter_mask);
>                         /* If we ran out of room on the first message,
>                          * we're in trouble
>                          */
>                         WARN_ON((err == -EMSGSIZE) && (skb->len == 0));
>
> That is -- it tries to fill the skb (for sending it back to
> userspace), but doesn't have enough room, so it returns -EMSGSIZE.
> That seems like reasonable behavior, but it doesn't really help me
> obtain my goal. I'd like to send quite a bit of data back to userspace
> for a network interface, and I'd like to do it using the standard
> netlink APIs. Is this possible?



What kind of data are you sending up?  Maybe there is an alternate interface.
