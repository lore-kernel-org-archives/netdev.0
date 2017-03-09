From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] dccp/tcp: fix routing redirect race
Date: Wed, 08 Mar 2017 20:40:54 -0800
Message-ID: <1489034454.28631.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489022121-20571-1-git-send-email-jmaxwell37@gmail.com>
         <1489025457.28631.19.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAGHK07BME+defjxsZZPFxyo2wEgbD2gJKMDerawCS4aLN3RdVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        kuznet <kuznet@ms2.inr.ac.ru>, jmorris <jmorris@namei.org>,
        yoshfuji <yoshfuji@linux-ipv6.org>, kaber <kaber@trash.net>,
        Neal Cardwell <ncardwell@google.com>, dccp@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jon Maxwell <jmaxwell@redhat.com>,
        Eric Garver <egarver@redhat.com>,
        Hannes Sowa <hsowa@redhat.com>
To: Jonathan Maxwell <jmaxwell37@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33385 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751968AbdCIEk5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 23:40:57 -0500
In-Reply-To: <CAGHK07BME+defjxsZZPFxyo2wEgbD2gJKMDerawCS4aLN3RdVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-09 at 14:42 +1100, Jonathan Maxwell wrote:
> Sorry let me resend in plain text mode.
> 
> On Thu, Mar 9, 2017 at 1:10 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2017-03-09 at 12:15 +1100, Jon Maxwell wrote:
> >> We have seen a few incidents lately where a dst_enty has been freed
> >> with a dangling TCP socket reference (sk->sk_dst_cache) pointing to that
> >> dst_entry. If the conditions/timings are right a crash then ensues when the
> >> freed dst_entry is referenced later on. A Common crashing back trace is:
> >
> > Very nice catch !
> >
> 
> Thanks Eric.
> 
> > Don't we have a similar issue for IPv6 ?
> >
> >
> 
> Good point.
> 
> We checked and as far as we can tell IPv6 does not invalidate the route.
> So it should be safer.

Simply doing :

__sk_dst_check(sk, np->dst_cookie);

is racy, even before calling dst->ops->redirect(dst, sk, skb);

(if socket is owned by user)
