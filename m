From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Why do we prefer skb->priority to tc filters?
Date: Wed, 11 Mar 2015 13:09:42 -0700
Message-ID: <1426104582.11398.61.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHA+R7Oz=Je_avfzjLib0YaQRUArEpt+sm1qNqcV_oEvUp3=eA@mail.gmail.com>
	 <CAHA+R7Os6=uxTAYr=0ZrCKZpySNJ4QoT=mJa5daGJ_0zgD1Y7w@mail.gmail.com>
	 <1426098340.11398.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7Pa6ypGoUr5jJfbayzwjLA-C78NOa1iPmsbmx+wXP56AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35855 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbbCKUJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:09:44 -0400
Received: by igkb16 with SMTP id b16so43591606igk.1
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 13:09:44 -0700 (PDT)
In-Reply-To: <CAHA+R7Pa6ypGoUr5jJfbayzwjLA-C78NOa1iPmsbmx+wXP56AA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 12:18 -0700, Cong Wang wrote:
> This is exactly why I am asking, kernel respects user's choice so much
> that it could override even both cgroup prio and tc filters, I don't know
> what is the reason behind, but this means our tc filters can not work
> with an application which sets skb->priority. For example, our tc filters
> classify the packets from this socket into flow 1:1, but application
> sets 1:2 by itself...

Application cannot set whatever skb->priority, unless it really knows
better than kernel.

        case SO_PRIORITY:
                if ((val >= 0 && val <= 6) ||
                    ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
                        sk->sk_priority = val;
                else
                        ret = -EPERM;
                break;
