From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next 3/3] net: Use l3_dev instead of skb->dev for L3 processing
Date: Tue, 8 Mar 2016 10:42:32 -0800
Message-ID: <CAF2d9jh7fbGgibzTgRfNppgVi2tm9j8p6OJHxiaR0ZmGzLe4dg@mail.gmail.com>
References: <1456783704-18746-1-git-send-email-mahesh@bandewar.net>
 <CAM_iQpXmoSZhNw+CCbFw5b6Dzq4W+vt5WH8FmRc1ZiuJgv1xnQ@mail.gmail.com>
 <CAF2d9jhopDVGxsSM3wfYh2XgENebJNbEOn9D7Vb8t13bQ7dRcQ@mail.gmail.com>
 <CAF2d9jiyjThgeQKw==tKRk3Sh0dNfzUdwJciwsVGPFLdb9uGTA@mail.gmail.com>
 <CAM_iQpUB_b3S_Mi8QyzhX_XBog3+ZshY8xbSby5eUytnG2OQRg@mail.gmail.com>
 <CAF2d9jhgoWeZdPkM-aev6j9a8OjUQ78CbE7dgp1wPXu91qp_-A@mail.gmail.com>
 <CAM_iQpVoRuWgk6_x-MWj=A520XjpC3e2QoPspQG6pfd--+m=KA@mail.gmail.com>
 <CAF2d9jg2ioCsRa+FHUnwEYSXmqszd6h8MFOcWpWaT4ikaUKc0w@mail.gmail.com> <CAM_iQpXHHMvbOMO5iG8jhk5yz3CyxB0641FYhcRPA65HL7DLjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:34051 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbcCHSnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 13:43:03 -0500
Received: by mail-yk0-f182.google.com with SMTP id x17so10123370ykd.1
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 10:42:57 -0800 (PST)
In-Reply-To: <CAM_iQpXHHMvbOMO5iG8jhk5yz3CyxB0641FYhcRPA65HL7DLjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 7, 2016 at 9:37 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Mar 4, 2016 at 2:12 PM, Mahesh Bandewar <maheshb@google.com> wrote:
>>
>> Unfortunately we don't have a way to switch to ns after L3 processing.
>
> I am totally aware of this, this is exactly why I said this might not be easy.
>
> The question is how hard it is to implement one? My gut feeling is we only
> need to change some data in skb, something similar to skb_scrub_packet().
> But I never even try.
>
>> So I would
>> argue it the other-way around. The way it is now; breaks the _isolation_ model.
>> If the default-ns is responsible for whole L3 (in this situation) and
>> it does pretty well
>> on egress but there is no way to do that in ingress path. IPtables is
>> not the only thing,
>> how about routing, how about IPsec? None of this will function well.
>> So we need to
>> have a generic solution to solve all these problems.
>
> I don't understand why you question me this, it is you who only cares
> about iptables from your cover letter for this patchset, not me.
>
calm down! I'm not questioning you or anyone. There is problem and I would
prefer to solve it properly without cooking-up some short-term hack. The problem
reported is about IPtable and when I looked at it, I felt that it's
just a matter of
time until someone tries / uses IPsec or some routing. So I created
this solution.
I did mention about *complete* L3 processing in the cover letter but
agree that I
emphasized only on IPtables which I can correct it in the next version.

> The more subsystems involves, the more struct net pointers you
> potentially need to touch, the less likely you can make it correct
> by just switching skb->dev.

Please drop that prejudice and read the patch-set carefully. I'm
neither changing
any *net* pointers nor changing the skb->dev pointers anywhere. All I'm saying
is dev->l3_dev is what we'll use for *all* L3 processing and no need to change
skb->dev or net-ns of any device(s) involved.
