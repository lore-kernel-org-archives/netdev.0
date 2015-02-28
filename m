From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] netns: avoid allocating idr when dumping info
Date: Fri, 27 Feb 2015 22:17:27 -0800
Message-ID: <CAM_iQpV7sVimr+3BzA8ZYW-wixwxv29r4jGZFB1FfUwCGN8QxA@mail.gmail.com>
References: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>
	<1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<54F09A95.8000507@6wind.com>
	<CAM_iQpUPQVodJRGmf=GYOVK+R_84w-+yDtqyHCJGbCDH0hb44A@mail.gmail.com>
	<54F0AE0B.5080101@6wind.com>
	<CAM_iQpUBp9bZGWTjq5UhFz4Z0Zt3YF-6cwkZafd54WP9cP8H+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34122 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbbB1GR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 01:17:27 -0500
Received: by pabrd3 with SMTP id rd3so28269487pab.1
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 22:17:27 -0800 (PST)
In-Reply-To: <CAM_iQpUBp9bZGWTjq5UhFz4Z0Zt3YF-6cwkZafd54WP9cP8H+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Removing Eric from discussion since he expressed he doesn't
care this code at all in a private email.)


On Fri, Feb 27, 2015 at 4:56 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
> Why? This relies on rtnetlink to dump the link after creation,
> which is not obvious at all. IOW, imagine if rtnetlink didn't do
> the dump after new link, what would happen?
>
> You are hiding it too deep, without a valid reason. It sounds
> like you want to defer the allocation as late as possible,
> but again it makes no sense: 1) we don't allocate too much,
> just one id in idr; 2) this loses the code readability and hides
> potential bugs.
>

Here we go:

This breaks veth, where veth peers are completely equal,
therefore they are links for each other. So we expect
link-netnsid shown on both side.

Your current impl. relies on rtnl_configure_link() to dump
the link to allocate the netns id after creating a link.
Unfortunately for veth, rtnl_configure_link() is called
before veth->peer is set, therefore the dump of the "peer"
does _not_ actually allocate the netns id, since its
->get_link_net() returns the same net.

I will send a patch together after I figure out another bug
I saw.
