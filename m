From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: add recursion limit to GRO
Date: Mon, 10 Oct 2016 07:03:56 -0700
Message-ID: <1476108236.28155.299.camel@edumazet-glaptop3.roam.corp.google.com>
References: <8fb8ec65c178b4d37951c4538dedc880eef068d4.1476106975.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jiri Benc <jbenc@redhat.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35395 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752642AbcJJOD7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 10:03:59 -0400
Received: by mail-io0-f196.google.com with SMTP id p26so7435189ioo.2
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 07:03:59 -0700 (PDT)
In-Reply-To: <8fb8ec65c178b4d37951c4538dedc880eef068d4.1476106975.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-10-10 at 15:43 +0200, Sabrina Dubroca wrote:
> Currently, GRO can do unlimited recursion through the gro_receive
> handlers.  This was fixed for tunneling protocols by limiting tunnel GRO
> to one level with encap_mark, but both VLAN and TEB still have this
> problem.  Thus, the kernel is vulnerable to a stack overflow, if we
> receive a packet composed entirely of VLAN headers.
> 
> This patch adds a recursion counter to the GRO layer to prevent stack
> overflow.  When a gro_receive function hits the recursion limit, GRO is
> aborted for this skb and it is processed normally.
> 
> Thanks to Vladimír Beneš <vbenes@redhat.com> for the initial bug report.


Hi Sabrina

Have you considered using a per cpu counter ?

It might be cheaper than using a 4-bit field in skb.

Really this counter does not need to be stored in skb. GRO already uses
way too much space in skb->cb[]

Also please add appropriate unlikely() clauses, since most GRO traffic
is not trying to kill hosts ;)

Thanks.
