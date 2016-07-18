From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 18 Jul 2016 06:26:00 -0400
Message-ID: <578CAEB8.9070805@mojatatu.com>
References: <1468744884-8246-1-git-send-email-jhs@emojatatu.com>
 <20160718041933.GB36253@ast-mbp.thefacebook.com>
 <578C7C5C.2070804@mojatatu.com> <578CA4EB.7060703@iogearbox.net>
 <20160718100717.GB30532@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, nikolay@cumulusnetworks.com
To: Thomas Graf <tgraf@suug.ch>, Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36310 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbcGRK0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 06:26:14 -0400
Received: by mail-qk0-f196.google.com with SMTP id q8so10715192qke.3
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 03:26:14 -0700 (PDT)
In-Reply-To: <20160718100717.GB30532@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-18 06:07 AM, Thomas Graf wrote:

>
> Right. I was at the same point as Jamal and it is nasty to try and
> reverse engineer the dumps without any further hints. I assume that's
> what he is referring to with difficulties.
>

That +: if you get me a field which says "dstmac" i dont have to go
and start aggregating 32bit chunks to create a 48bit MAC (or worse
look at the offset and figure where they come from).

> Looking back, I would simply calculate a SHA hash over the original
> filter in text form, pass the hash together with the tc filter and then
> associate the hash with the filter text stored in user space. This
> would not only benefit pedit but also u32 and possibly others.
>

A "cookie" tag that is sent to the kernel would serve the purpose.
We would need to standardize what the meaning of such a cookie is.

> It also has the advantage that extending the kernel once now will allow
> to add additional higher level abstractions later on without requiring
> users to rebase their kernels.
>

Yes - and btw it works well with hardware offloads. It is a good free
form "assembler" level. But i dont think it serves well when we have
known often-used cases such as these.
It is like doing tcp over raw sockets - at some point it becomes more
efficient and more usable to just introduce tcp sockets. Thats all I
am asking for.

cheers,
jamal
