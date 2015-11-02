From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Exporting obscene amounts of data in rtnl_link_ops->fill_info()
Date: Mon, 2 Nov 2015 04:25:36 +0100
Message-ID: <CAHmME9povw2sGHWUM285oieNYW=EDdEBwH+F0L1C=k=cxAv45g@mail.gmail.com>
References: <CAHmME9pps6BJwubBNgp294JKGkGXHUyb1kMdTGCEwok__aQjmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9pps6BJwubBNgp294JKGkGXHUyb1kMdTGCEwok__aQjmw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi folks,

Just a follow-up on this thread...

The basic issue is that for a given net device, I want to export to
userspace more data than what can fit in a netlink sk_buff. On first
glance, using RTM_GETLINK with the ops->fill_info() hook seemed
perfect. It provides a simple interface for my rtnetlink driver to
provide additional information back to userspace. Unfortunately, the
size of messages it can export back to userspace is limited, as
mentioned.

So, I see two options from here:

One is registering a new type of netlink message for a new PF, with
rtnl_register(). Inside of this, I'd have a more clean API of sending
back information in chunks, which can fit inside a netlink packet.

The other is to implement ops->ndo_do_ioctl() with a very simple
mechanism of copying structs back to userspace, directly into
userspace-allocated buffers. This would be _much_ simpler and easier
to implement, and probably less prone to race-conditions too.

So I want to add the ioctl. I can practically already see the code in
my head. But everywhere I look, folks are turning to netlink. It's
hard to imagine a new driver passing review on this mailing list if it
adds "yet another" ioctl interface. So, I'm then pushed toward doing
the awkward netlink dance, because "all the cool kids are doing it."

But, before I succumb to what is potentially a false dichotomy, I
thought I'd write in here to get some opinions on the best way
forward. To repeat, the basic idea is - I need to return lots of
per-interface information to userspace from a netdevice. RTM_GETLINK
has a maximum message size, so it won't do. What's the cleanest and
most acceptable way forward?

Thanks,
Jason
