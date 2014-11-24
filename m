From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: qstats update in packet scheduling
Date: Mon, 24 Nov 2014 12:21:59 -0800
Message-ID: <1416860519.17888.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHmvzZQnBJbx3hfdvpXg0TZM-UooKxjM+-1HO6nSSpx4qJLcaw@mail.gmail.com>
	 <1416850289.17888.67.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHmvzZRwsd7S+T4cdAVzWGORcbkq+WWMtFAV6Ss3UrA+Ogeujg@mail.gmail.com>
	 <1416854568.17888.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAA93jw4URTCK_O5mrJB14qAraubqj4Y-pvWMFX7ts=BWSgd-Og@mail.gmail.com>
	 <CAHmvzZTF76DwdyBF9og2v9Vumx5v0BhHR584uX54o5R+T+iUMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Taht <dave.taht@gmail.com>, netdev <netdev@vger.kernel.org>
To: Josh Clark <jcinma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:58082 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752832AbaKXUWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 15:22:02 -0500
Received: by mail-ig0-f171.google.com with SMTP id uq10so3778571igb.16
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 12:22:01 -0800 (PST)
In-Reply-To: <CAHmvzZTF76DwdyBF9og2v9Vumx5v0BhHR584uX54o5R+T+iUMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-24 at 14:14 -0500, Josh Clark wrote:

> At the moment, I'm using standard RED (from /net/sched/sch_red.c) with
> some printks to output qstats.

printk are slowing down the kernel and might interfere with normal
behavior. Don't use them.


> Are you saying that when I set this up, I need to use the -s flag in
> tc to maintain those statistics?

stats are maintained by the kernel no matter what.

tc -s qdisc   actually display them.

For instance, red_dump() copies the backlog from child qdisc.

static int red_dump(struct Qdisc *sch, struct sk_buff *skb)
{
...
	sch->qstats.backlog = q->qdisc->qstats.backlog;
...
}



This backlog is probably not 0 !
