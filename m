From: Cong Wang <cwang@twopensource.com>
Subject: Re: Why do we prefer skb->priority to tc filters?
Date: Thu, 12 Mar 2015 10:08:29 -0700
Message-ID: <CAHA+R7PrxZKaRsjUBxLaitNdZwute-0saOxj+hza8zCya-hT2Q@mail.gmail.com>
References: <CAHA+R7Oz=Je_avfzjLib0YaQRUArEpt+sm1qNqcV_oEvUp3=eA@mail.gmail.com>
	<CAHA+R7Os6=uxTAYr=0ZrCKZpySNJ4QoT=mJa5daGJ_0zgD1Y7w@mail.gmail.com>
	<1426098340.11398.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7Pa6ypGoUr5jJfbayzwjLA-C78NOa1iPmsbmx+wXP56AA@mail.gmail.com>
	<1426104582.11398.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7M8EFF=y7LOqsiHMsT+Q1e+3wxAE93njkSk3p9nYc2gTA@mail.gmail.com>
	<1426110450.11398.84.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+GmxbbGHXrZ6OrwPm0WBzk89iK94wyzJJAqbqw_XbVELvy9nQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Dmitry Sytchev <kbdfck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:45796 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932409AbbCLRIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 13:08:30 -0400
Received: by igjz20 with SMTP id z20so17963358igj.4
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 10:08:29 -0700 (PDT)
In-Reply-To: <CA+GmxbbGHXrZ6OrwPm0WBzk89iK94wyzJJAqbqw_XbVELvy9nQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 12:53 AM, Dmitry Sytchev <kbdfck@gmail.com> wrote:
> Sorry for slight offtopic, but for some reason, recent netfilter SET
> changes, which allow setting queue number and priority via ipset
> skbinfo extension, don't work with multiple HTB on top of multiq or
> mq.

Can you show us your setup? `iptables -L` and `tc qd show dev ...`,
`tc class show dev ...` etc.


> At the same time, tc filters set on outbound iface with skbedit works
> fine both for prio and queue number.
> How can I find the difference in their behaviour to trace where queue
> number set by ipset match gets lost?

There are fewer places to set skb->queue_mapping than skb->priority.
Since you are using mq, you can watch the `tc -s -d class show dev ...`
output to see if your packets go to the desired queue.
