From: "Maciej W. Rozycki" <macro@imgtec.com>
Subject: Re: BPF relocations
Date: Sun, 21 May 2017 04:22:45 +0100
Message-ID: <alpine.DEB.2.00.1705210354330.2590@tp.orcam.me.uk>
References: <20170511.153118.2082025756694634804.davem@davemloft.net>        <b39b79d6-4fe2-f887-dc7e-03b62d6eb3e4@fb.com> <20170511.211920.2220259143750653022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <ast@fb.com>, <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:33369 "EHLO
        mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755431AbdEUDX1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 May 2017 23:23:27 -0400
In-Reply-To: <20170511.211920.2220259143750653022.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 May 2017, David Miller wrote:

> Internally, we have to emit some kind of relocation as GAS makes it's
> first pass over the instructions.

 Not really, you can defer that until the relaxation pass, e.g. to avoid 
figuring out what to do about forward local symbol references, especially 
in complex expressions that may eventually resolve to assembly constants.

 This is how MIPS16 assembly works for example, due to its dual regular vs 
extended instruction encoding, so that no artificial relocations had to be 
invented in GAS for the regular instructions, which never get relocations 
recorded against in an object file.  Any instruction that ends up needing 
a relocation, if supported (not all encodings do), gets converted to the 
extended form in the relaxation pass and only then a suitable fixup is 
attached to it.

 Of course that may not matter for your specific case, but I think it's 
worth noting so as to avoid people getting misled about how GAS works.

 FWIW,

  Maciej
