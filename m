From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel encapsulation
Date: Thu, 3 Nov 2016 09:20:01 -0600
Message-ID: <CACby=pmSSG5P+7=wDvqwkVp_yXw9o8_pREZCLfDov_XFbueFAQ@mail.gmail.com>
References: <cover.1477959702.git.tgraf@suug.ch> <c220b6b2-3f20-09ff-2068-6ecfe0b47b9e@stressinduktion.org>
 <CACby=pmK9Pj00LYx9PQrgWe95xmy=qFhpjSYZT=QDnLQ55J=8w@mail.gmail.com>
 <1478030932.3136562.774196097.1F1AD6FB@webmail.messagingengine.com>
 <CACby=p=sSPfh0Lxr2qqk+wQ1=LVQvDU785Z9eTnT1GcKK=RoxA@mail.gmail.com>
 <3f9e7de1-1e61-2fb5-9529-c46343ac39c9@stressinduktion.org>
 <CACby=pnSX15XGuKBcw2FJkLz_qZt6XE+JS4ySN1Z6OZ=+w_eoQ@mail.gmail.com> <c24f3ad9-764a-0ffa-51bf-2b42fb3ae585@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Tom Herbert <tom@herbertland.com>,
        roopa <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:34553 "EHLO
        mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756922AbcKCPUD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 11:20:03 -0400
Received: by mail-vk0-f51.google.com with SMTP id x186so42445631vkd.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 08:20:03 -0700 (PDT)
In-Reply-To: <c24f3ad9-764a-0ffa-51bf-2b42fb3ae585@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3 November 2016 at 08:52, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 02.11.2016 23:54, Thomas Graf wrote:
>> Why would I want to accept the overhead if I simply avoid it? Just
>> parsing the header and doing the hash lookup will add cost, cost for
>> each packet.
>
> That is true, but in case you are outside of the namespace, you still
> have to calculate the cost of doing the FIB lookup for the BPF program
> each time, too.
>
> E.g. given the lookup cost in a hash for a netnwork namespace pointer
> vs. the cost of doing a FIB lookup to get a program that does a specific
> transformation sounds at least in the big O-notiation to be in a better
> place. ;)
>
> If you have to do both anyway, probably your patchset will perform
> better, I agree.

Most containers are unprivileged, the route inside the container's
namespace is owned by the host and we can attach the BPF program
directly to the default route inside the container and all packets
egressing from the container will pass through it. That fib lookup is
needed anyway so we can leverage the cost of that lookup. We can drop
hostile packets early without ever going on L2 level.
