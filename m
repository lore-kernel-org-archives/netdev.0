From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 18 Jul 2016 12:07:18 +0200
Message-ID: <20160718100717.GB30532@pox.localdomain>
References: <1468744884-8246-1-git-send-email-jhs@emojatatu.com>
 <20160718041933.GB36253@ast-mbp.thefacebook.com>
 <578C7C5C.2070804@mojatatu.com>
 <578CA4EB.7060703@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, nikolay@cumulusnetworks.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36735 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbcGRKHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 06:07:20 -0400
Received: by mail-wm0-f47.google.com with SMTP id f126so96682883wma.1
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 03:07:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <578CA4EB.7060703@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/16 at 11:44am, Daniel Borkmann wrote:
> Same for tcp, icmp, ipv6 bits code ... :/ Is it still planned to eventually
> complete these? I agree that from a usability PoV, it might be nice to
> have some kind of 'pretty printer' for it besides the existing config
> parser there (e.g. when we know that a loaded instance was done with a
> high-level module, we could annotate that for retrieval on dump or such).

Right. I was at the same point as Jamal and it is nasty to try and
reverse engineer the dumps without any further hints. I assume that's
what he is referring to with difficulties.

Looking back, I would simply calculate a SHA hash over the original
filter in text form, pass the hash together with the tc filter and then
associate the hash with the filter text stored in user space. This
would not only benefit pedit but also u32 and possibly others.

It also has the advantage that extending the kernel once now will allow
to add additional higher level abstractions later on without requiring
users to rebase their kernels.
