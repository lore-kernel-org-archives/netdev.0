From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH next 3/3] net: Use l3_dev instead of skb->dev for L3 processing
Date: Mon, 7 Mar 2016 21:37:46 -0800
Message-ID: <CAM_iQpXHHMvbOMO5iG8jhk5yz3CyxB0641FYhcRPA65HL7DLjA@mail.gmail.com>
References: <1456783704-18746-1-git-send-email-mahesh@bandewar.net>
	<CAM_iQpXmoSZhNw+CCbFw5b6Dzq4W+vt5WH8FmRc1ZiuJgv1xnQ@mail.gmail.com>
	<CAF2d9jhopDVGxsSM3wfYh2XgENebJNbEOn9D7Vb8t13bQ7dRcQ@mail.gmail.com>
	<CAF2d9jiyjThgeQKw==tKRk3Sh0dNfzUdwJciwsVGPFLdb9uGTA@mail.gmail.com>
	<CAM_iQpUB_b3S_Mi8QyzhX_XBog3+ZshY8xbSby5eUytnG2OQRg@mail.gmail.com>
	<CAF2d9jhgoWeZdPkM-aev6j9a8OjUQ78CbE7dgp1wPXu91qp_-A@mail.gmail.com>
	<CAM_iQpVoRuWgk6_x-MWj=A520XjpC3e2QoPspQG6pfd--+m=KA@mail.gmail.com>
	<CAF2d9jg2ioCsRa+FHUnwEYSXmqszd6h8MFOcWpWaT4ikaUKc0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f196.google.com ([209.85.160.196]:35516 "EHLO
	mail-yk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013AbcCHFhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 00:37:47 -0500
Received: by mail-yk0-f196.google.com with SMTP id p128so160740ykc.2
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 21:37:46 -0800 (PST)
In-Reply-To: <CAF2d9jg2ioCsRa+FHUnwEYSXmqszd6h8MFOcWpWaT4ikaUKc0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 4, 2016 at 2:12 PM, Mahesh Bandewar <maheshb@google.com> wrote:
>
> Unfortunately we don't have a way to switch to ns after L3 processing.

I am totally aware of this, this is exactly why I said this might not be easy.

The question is how hard it is to implement one? My gut feeling is we only
need to change some data in skb, something similar to skb_scrub_packet().
But I never even try.

> So I would
> argue it the other-way around. The way it is now; breaks the _isolation_ model.
> If the default-ns is responsible for whole L3 (in this situation) and
> it does pretty well
> on egress but there is no way to do that in ingress path. IPtables is
> not the only thing,
> how about routing, how about IPsec? None of this will function well.
> So we need to
> have a generic solution to solve all these problems.

I don't understand why you question me this, it is you who only cares
about iptables from your cover letter for this patchset, not me.

The more subsystems involves, the more struct net pointers you
potentially need to touch, the less likely you can make it correct
by just switching skb->dev.
