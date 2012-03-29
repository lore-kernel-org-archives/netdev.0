From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: bpf_slow_path: sibling call to `skb_copy_bits' not allowed multiple
 TOCs (ppc)
Date: Wed, 28 Mar 2012 20:54:56 -0400
Message-ID: <CAP=VYLqwbjNDQ-TTbs_6cH4X2MMzy=MAFy4=R116zGL8a6qUag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linuxppc-dev@ozlabs.org, linux-next@vger.kernel.org
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:43630 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933074Ab2C2Ay6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 20:54:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Wondering if anyone has researched this, before I waste more time on it.

The linux-next build of powerpc-allyesconfig has for quite some time shown this:

  LD      .tmp_vmlinux1
powerpc-linux-ld: arch/powerpc/net/built-in.o: In function `bpf_slow_path_word':
(.text+0x90): sibling call optimization to `skb_copy_bits' does not
allow automatic
multiple TOCs; recompile with -mminimal-toc or -fno-optimize-sibling-calls, or
make `skb_copy_bits' extern

We get the same error for s/word/half/ and s/word/byte/ and s/word/msh/

Visually "bisecting" the linux-next builds shows the following:

good: Dec 7th, 2011:  http://kisskb.ellerman.id.au/kisskb/buildresult/5059024/
bad:   Dec 8th, 2011:  http://kisskb.ellerman.id.au/kisskb/buildresult/5062069/

I wouldn't be surprised if this was some kind of size thing that doesn't matter
in the real world, as the powerpc-allyesconfig is really only of value for build
coverage.   Even in the absence of the skb error, it still fails to link with:

    "powerpc-linux-ld: TOC section size exceeds 64k"

i.e. it never links into anything a person could actually try and boot anyway.

So, just knowing "yes that is bogus because you've got a giant kernel
with multiple TOC" would be useful information here.

Thanks,
Paul.
