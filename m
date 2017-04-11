From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: eBPF - little-endian load instructions?
Date: Tue, 11 Apr 2017 13:15:30 +0200
Message-ID: <1491909330.31620.21.camel@sipsolutions.net>
References: <1491907114.31620.18.camel@sipsolutions.net>
         <58ECB8CF.8040409@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49598 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753071AbdDKLPc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 07:15:32 -0400
In-Reply-To: <58ECB8CF.8040409@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Are you working with an skb at that point in time in wifi? 

Yes.

> There are
> 3 different ways of accessing skb data, see [1] slide 7 - 10. The BPF
> LD_ABS/IND instructions were carried over from cBPF and are the only
> ones that convert to host endianess. It can be used in eBPF as well,
> but there are more efficient ways like 'direct packet access' or
> helpers such as bpf_skb_load_bytes() that load the raw buffers as-is,
> which is probably what you want if I understand you correctly.

Sounds like, yeah.

> There are instructions to convert endianess, see __bpf_prog_run(),
> the ALU_END_TO_BE, ALU_END_TO_LE labels for details. There's a
> BPF_ENDIAN() macro used in the test suite and other places.

Ok, thanks! :)

So sounds like I don't need anything special - should have a patch to
hook up the wifi stuff soon.

johannes
