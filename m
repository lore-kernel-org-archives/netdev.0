From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: eBPF - little-endian load instructions?
Date: Sat, 15 Apr 2017 09:06:11 +0200
Message-ID: <1492239971.4735.5.camel@sipsolutions.net>
References: <1491907114.31620.18.camel@sipsolutions.net>
         <58ECB8CF.8040409@iogearbox.net> <1492002120.2855.3.camel@sipsolutions.net>
         <20170412165804.GA75807@ast-mbp.thefacebook.com>
         <1492025919.2855.20.camel@sipsolutions.net>
         <20170413030818.GA42879@ast-mbp.thefacebook.com>
         <1492063125.19193.1.camel@sipsolutions.net>
         <20170414184228.GA41922@ast-mbp.thefacebook.com>
         (sfid-20170414_204234_987955_362A9588)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:52868 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751494AbdDOHGP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 15 Apr 2017 03:06:15 -0400
In-Reply-To: <20170414184228.GA41922@ast-mbp.thefacebook.com> (sfid-20170414_204234_987955_362A9588)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-14 at 11:42 -0700, Alexei Starovoitov wrote:

> bpf takes endianness of the cpu it runs on.

Ok, so then things are actually not as difficult as I thought.

> if we said that bpf 32-bit load insn is little endian, it would have
> screwed up all big-endian archs and the other way around.

Right.

But then basically we do only need to have builtins for endian
conversion, and #define them appropriately, as done anywhere else.

Perhaps we want to eventually be able to take advantage of "other-
endian" loads the CPU may have through the JIT, but getting it correct
first would be good :)

Either way though, it could be done with something like inline
assembly.

johannes
