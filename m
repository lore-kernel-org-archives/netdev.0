From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: commit f5f99309 (sock: do not set sk_err in
 sock_dequeue_err_skb) has broken ping
Date: Thu, 1 Jun 2017 16:31:42 +0200
Message-ID: <20170601143141.GB24401@rei.lan>
References: <20170601140048.GA24401@rei.lan>
 <CACSApvZiQTYSVkS62YdadjabUTqwO9O2=Sq4ELuO3eoJ_LM_ZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Pravin B Shelar <pshelar@ovn.org>,
        Eric Dumazet <edumazet@google.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Yaogong Wang <wygivan@google.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38466 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751078AbdFAObr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 10:31:47 -0400
Content-Disposition: inline
In-Reply-To: <CACSApvZiQTYSVkS62YdadjabUTqwO9O2=Sq4ELuO3eoJ_LM_ZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!
> > I've bisected the problem to this commit:
> >
> > commit f5f99309fa7481f59a500f0d08f3379cd6424c1f (HEAD, refs/bisect/bad)
> > Author: Soheil Hassas Yeganeh <soheil@google.com>
> > Date:   Thu Nov 3 18:24:27 2016 -0400
> >
> >     sock: do not set sk_err in sock_dequeue_err_skb
> 
> Hi Cyril,
> 
> I'm sorry for the problem, and thank you for the report.
> 
> Two questions:
> 1. Could you double check whether you have the following commit in your tree?
> 
> commit 83a1a1a70e87f676fbb6086b26b6ac7f7fdd107d
> Author: Soheil Hassas Yeganeh <soheil@google.com>
> Date:   Wed Nov 30 14:01:08 2016 -0500
>     sock: reset sk_err for ICMP packets read from error queue

I've started bisecting on v4.11 and see the problem on v4.10 on another
machine, the patch should be there in both cases and the bug is easily
reproducible.

> 2. I've also have sent a fix to iputils on
> https://github.com/iputils/iputils/pull/75. Would you be kind to try
> that pull request as well?

That fixed the problem, you can add:

Tested-by: Cyril Hrubis <chrubis@suse.cz>

-- 
Cyril Hrubis
chrubis@suse.cz
