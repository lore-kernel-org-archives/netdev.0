From: David Miller <davem@davemloft.net>
Subject: Re: BPF relocations
Date: Thu, 11 May 2017 21:19:20 -0400 (EDT)
Message-ID: <20170511.211920.2220259143750653022.davem@davemloft.net>
References: <20170511.153118.2082025756694634804.davem@davemloft.net>
        <b39b79d6-4fe2-f887-dc7e-03b62d6eb3e4@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56562 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752111AbdELBT0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 21:19:26 -0400
In-Reply-To: <b39b79d6-4fe2-f887-dc7e-03b62d6eb3e4@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 11 May 2017 16:10:35 -0700

> I don't see what we would use pc-relative relo for.

We must have them at least for banches.

Internally, we have to emit some kind of relocation as GAS makes it's
first pass over the instructions.

Afterwards, it walks the relocations and resolves all that can be done
at assembly time, and preserves as relocations in the object file for
those which it cannot.

Thinking further down the line many other kinds of PC relative
relocations are possible, even if you don't allow calls.  For example:

	ldimm64	R1, 24 + (. - external_label)

This would be a 64-bit PC relative reloc, with the value 24 in the
addend.

And eventually we want full linking.

The example above may seem silly, but every other full CPU ELF
specification handles these things completely and we should seek to be
complete as well.
