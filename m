From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next rfc 0/6] convert tc_verd to integer bitfields
Date: Tue, 3 Jan 2017 12:05:07 -0500
Message-ID: <CAF=yD-Lt7yOObrphvqo7PsEDaLCz=P5ku20g8GViNT-d+Bi0og@mail.gmail.com>
References: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <c32d7b7c-3dd3-2d75-5f9a-e356f1fc7732@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>, dborkman@iogearbox.net,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Roman Mashak <mrv@mojatatu.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:36461 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759730AbdACRFt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 12:05:49 -0500
Received: by mail-ua0-f193.google.com with SMTP id v2so18137021uac.3
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 09:05:48 -0800 (PST)
In-Reply-To: <c32d7b7c-3dd3-2d75-5f9a-e356f1fc7732@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> No objections to new year resolution of slimming the skb.
> But: i am still concerned about the recursion that getting rid of
> some of these bits could embolden. i.e my suggestion was infact to
> restore some of those bits taken away by Florian after the ingress
> redirect patches from Shmulik.
>
> The possibilities are: egress->egress, egress->ingress,
> ingress->egress, ingress->ingress. The suggestion was
> xmit_recursion with some skb magic would suffice.
> Hannes promised around last netdevconf that he has a scheme to solve
> it without using any extra skb state.

Are you referring to

"
Personally, I would only try to fix and warn against the easy to detect
cases. It is easy enough to just create a loop with your local attached
L2 which brings your box into a endless loop processing the same packet
again and again. Because it is out of control of the kernel you cannot
do anything at all.

I would just care that we sometimes reschedule and don't do everything
in one stack so we don't corrupt the machine and an admin has still a
chance to solve the problem.
"
https://www.spinics.net/lists/netdev/msg397498.html

That can be solved by extending act_mirred in the same way as
Daniel did for bpf_redirect in a70b506efe89 ("bpf: enforce recursion
limit on redirects").
