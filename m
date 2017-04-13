From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: eBPF - little-endian load instructions?
Date: Thu, 13 Apr 2017 07:58:45 +0200
Message-ID: <1492063125.19193.1.camel@sipsolutions.net>
References: <1491907114.31620.18.camel@sipsolutions.net>
         <58ECB8CF.8040409@iogearbox.net> <1492002120.2855.3.camel@sipsolutions.net>
         <20170412165804.GA75807@ast-mbp.thefacebook.com>
         <1492025919.2855.20.camel@sipsolutions.net>
         <20170413030818.GA42879@ast-mbp.thefacebook.com>
         (sfid-20170413_050826_067766_04CFF6B3)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:50072 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751438AbdDMF6t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 01:58:49 -0400
In-Reply-To: <20170413030818.GA42879@ast-mbp.thefacebook.com> (sfid-20170413_050826_067766_04CFF6B3)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-12 at 20:08 -0700, Alexei Starovoitov wrote:

> it's really llvm bug that i need fix. It's plain broken
> to generate what effectively is nop insn for march=bpfeb
> My only excuse that when that code was written llvm had only
> march=bpfel.
> bpfeb was added much later.

So I'm confused now. Is bpf intended to be endian-independent or not?
It sounded at first like it was, even if I have a hard time imagining
how that would even work.

> > 	#define be32_to_cpu bswap32
> > or
> > 	#define be32_to_cpu(x) (x)
> > depending on the build architecture, I guess.
> 
> yeah. that's what we should have in bpf_helpers.h

But that sounds more like it isn't.

> ntoh is enough for any networking code,
> so I guess we can live without real bswap insn.

Well, my reason for asking this is that wireless actually as a little-
endian wire protocol, unlike other network stuff :)
(Even at a bit level it's defined to transfer the LSB first, but that
doesn't really get visible at the level of the CPU that can only
address bytes.)

johannes
