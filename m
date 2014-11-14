From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fast_hash: clobber registers correctly for
 inline function use
Date: Fri, 14 Nov 2014 07:33:01 -0800
Message-ID: <1415979181.17262.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <4086c7bc9f7f9e8e2de9656c9e27ef1e71bb6423.1415973706.git.hannes@stressinduktion.org>
	 <1415976656.17262.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1415978022.15154.31.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, pshelar@nicira.com,
	jesse@nicira.com, jay.vosburgh@canonical.com,
	discuss@openvswitch.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:59075 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965892AbaKNPdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 10:33:04 -0500
Received: by mail-ie0-f180.google.com with SMTP id rl12so2614157iec.25
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 07:33:03 -0800 (PST)
In-Reply-To: <1415978022.15154.31.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-14 at 16:13 +0100, Hannes Frederic Sowa wrote:
> > 
> > 
> > Thats a lot of clobbers.
> 
> Yes, those are basically all callee-clobbered registers for the
> particular architecture. I didn't look at the generated code for jhash
> and crc_hash because I want this code to always be safe, independent of
> the version and optimization levels of gcc.
> 
> > Alternative would be to use an assembly trampoline to save/restore them
> > before calling __jhash2
> 
> This version provides the best hints on how to allocate registers to the
> optimizers. E.g. it could avoid using callee-clobbered registers but use
> callee-saved ones. If we build a trampoline, we need to save and reload
> all registers all the time. This version just lets gcc decide how to do
> that.
> 
> > __intel_crc4_2_hash2 can probably be written in assembly, it is quite
> > simple.
> 
> Sure, but all the pre and postconditions must hold for both, jhash and
> intel_crc4_2_hash and I don't want to rewrite jhash in assembler.

We write optimized code for current cpus.

With current generation of cpus, we have crc32 support.

The fallback having to save/restore few registers, we don't care, as the
fallback has huge cost anyway.

You don't have to write jhash() in assembler, you misunderstood me.

We only have to provide a trampoline in assembler, with maybe 10
instructions.

Then gcc will know that we do not clobber registers for the optimized
case.
