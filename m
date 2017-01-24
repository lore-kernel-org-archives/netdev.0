From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Mon, 23 Jan 2017 18:39:56 -0800
Message-ID: <CALCETrUz1701E5JS5NEqEqeGLExnxpesU44dSi2eYK4iMu=kcQ@mail.gmail.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <20170124020950.GA72992@ast-mbp.thefacebook.com> <678f4d6f-e2f8-eb37-207a-c77269507f9d@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f172.google.com ([209.85.217.172]:35792 "EHLO
        mail-ua0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbdAXCkS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 21:40:18 -0500
Received: by mail-ua0-f172.google.com with SMTP id y9so125109471uae.2
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 18:40:17 -0800 (PST)
In-Reply-To: <678f4d6f-e2f8-eb37-207a-c77269507f9d@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 6:31 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 1/23/17 7:09 PM, Alexei Starovoitov wrote:
>>> +     */
>>> +    if (current->nsproxy->net_ns != &init_net)
>>> +            return -EINVAL;
>>
>> this restriction I actually don't mind, since it indeed can be
>> relaxed later, but please make it proper with net_eq()
>>
>
> I do mind. Why have different restrictions for the skb and sk filters?
>
> I have already shown that ip can alleviate the management aspects of the implementation -- just like ip netns does.

I'm not sure I followed what you meant.  If I understood right (which
is a big if) you're saying that ip vrf when run in a netns works
correctly in that netns.  I agree, but I think that it would continue
to work (even more reliably) if the hooks only executed in the netns
in which they were created.  I think that would probably be a good
improvement, and it could be done on top of my patch, but I'm not
about to write that code for 4.10.

--Andy
