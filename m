From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: __sk_buff.data_end
Date: Thu, 20 Apr 2017 08:01:05 +0200
Message-ID: <1492668065.3109.1.camel@sipsolutions.net>
References: <1492637460.22185.6.camel@sipsolutions.net>
                 (sfid-20170419_233114_060429_CAFE85B8) <1492640459.22185.7.camel@sipsolutions.net>
         <58F7FA6D.5030000@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51074 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1765656AbdDTGBM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 02:01:12 -0400
In-Reply-To: <58F7FA6D.5030000@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-20 at 02:01 +0200, Daniel Borkmann wrote:
> 
> Yeah, should work as well for the 32 bit archs, on 64 bit we
> have this effectively already:

Right.

[...]

> Can you elaborate on why this works for mac80211? It uses cb
> only up to that point from where you invoke the prog?

No, it works because then I can move a u64 field to the same offset,
and save/restore it across the BPF call :)

But I don't have a *pointer* field to move there, and no space for the
alignment anyway (already using all 48 bytes).

Come to think of it - somebody had proposed extensions to this by
passing an on-stack pointer in addition to the data in the cb.

Perhaps we can extend BPF to have an optional second argument, and
track a second context around the verifier, if applicable? Then we can
solve all of this really easily, because it means we don't always have
to go from the SKB context but could go from the other one (which could
be that on-stack buffer).

Alternatively I can clear another pointer (u64) in the CB, store a
pointer there, and always emit code following that pointer - should be
possible right?

johannes
