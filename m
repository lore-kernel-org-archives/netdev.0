From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel encapsulation
Date: Wed, 2 Nov 2016 16:57:36 -0600
Message-ID: <CACby=p=Vnd96Y0g8xfOfz9j8jDNmhASBYV+yM7Fx7G=H=BSsRQ@mail.gmail.com>
References: <cover.1477959702.git.tgraf@suug.ch> <c220b6b2-3f20-09ff-2068-6ecfe0b47b9e@stressinduktion.org>
 <CACby=pmK9Pj00LYx9PQrgWe95xmy=qFhpjSYZT=QDnLQ55J=8w@mail.gmail.com>
 <1478030932.3136562.774196097.1F1AD6FB@webmail.messagingengine.com>
 <CACby=p=sSPfh0Lxr2qqk+wQ1=LVQvDU785Z9eTnT1GcKK=RoxA@mail.gmail.com>
 <3f9e7de1-1e61-2fb5-9529-c46343ac39c9@stressinduktion.org> <CALx6S37s-pTxgqje9+FgmuvVgSZONGURAmJOemL6pOc6_Oepew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        roopa <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:35420 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754442AbcKBW5i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 18:57:38 -0400
Received: by mail-vk0-f42.google.com with SMTP id w194so25719362vkw.2
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 15:57:38 -0700 (PDT)
In-Reply-To: <CALx6S37s-pTxgqje9+FgmuvVgSZONGURAmJOemL6pOc6_Oepew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 November 2016 at 17:07, Tom Herbert <tom@herbertland.com> wrote:
> On the other hand, I'm not really sure how to implement for this level
> of performance this in LWT+BPF either. It seems like one way to do
> that would be to create a program each destination and set it each
> host. As you point out would create a million different programs which
> doesn't seem manageable. I don't think the BPF map works either since
> that implies we need a lookup (?). It seems like what we need is one
> program but allow it to be parameterized with per destination
> information saved in the route (LWT structure).

Attaching different BPF programs to millions of unique dsts doesn't
make any sense. That will obivously will never scale and it's not
supposed to scale. This is meant to be used for prefixes which
represent a series of endpoints, f.e. all local containers, all
non-internal traffic, all vpn traffic, etc. I'm also not sure why we
are talking about ILA here, you have written a native implementation,
why would you want to solve it with BPF again?

If you want to run a single program for all dsts, feel free to run the
same BPF program for each dst. Nobody is forcing you to attach
individual programs.
