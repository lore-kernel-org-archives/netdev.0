From: Cong Wang <cwang@twopensource.com>
Subject: Re: Why do we prefer skb->priority to tc filters?
Date: Wed, 11 Mar 2015 13:46:12 -0700
Message-ID: <CAHA+R7M8EFF=y7LOqsiHMsT+Q1e+3wxAE93njkSk3p9nYc2gTA@mail.gmail.com>
References: <CAHA+R7Oz=Je_avfzjLib0YaQRUArEpt+sm1qNqcV_oEvUp3=eA@mail.gmail.com>
	<CAHA+R7Os6=uxTAYr=0ZrCKZpySNJ4QoT=mJa5daGJ_0zgD1Y7w@mail.gmail.com>
	<1426098340.11398.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7Pa6ypGoUr5jJfbayzwjLA-C78NOa1iPmsbmx+wXP56AA@mail.gmail.com>
	<1426104582.11398.61.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:35595 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbCKUqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:46:13 -0400
Received: by ieclw3 with SMTP id lw3so5494936iec.2
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 13:46:13 -0700 (PDT)
In-Reply-To: <1426104582.11398.61.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 1:09 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-03-11 at 12:18 -0700, Cong Wang wrote:
>> This is exactly why I am asking, kernel respects user's choice so much
>> that it could override even both cgroup prio and tc filters, I don't know
>> what is the reason behind, but this means our tc filters can not work
>> with an application which sets skb->priority. For example, our tc filters
>> classify the packets from this socket into flow 1:1, but application
>> sets 1:2 by itself...
>
> Application cannot set whatever skb->priority, unless it really knows
> better than kernel.
>
>         case SO_PRIORITY:
>                 if ((val >= 0 && val <= 6) ||
>                     ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
>                         sk->sk_priority = val;
>                 else
>                         ret = -EPERM;
>                 break;
>

That is just a permission check when val > 6, given the fact most
daemons have root permission, I doubt your argument makes a difference
for discussion. At least with userns having root permission is more common.
