From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH v2] net: filter: BPF 'JIT' compiler for PPC64
Date: Tue, 19 Jul 2011 02:17:31 -0500
Message-ID: <CBA05A49-86F1-40FF-9244-0E4D29EBBA48@kernel.crashing.org>
References: <4E23E5C3.1070209@ozlabs.org> <4E24E867.9050909@ozlabs.org> <51978BAA-10A1-483D-B551-CCC2B69C72EA@kernel.crashing.org> <4E252CFE.4070408@ozlabs.org>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Matt Evans <matt@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:55584 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174Ab1GSHRl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 03:17:41 -0400
In-Reply-To: <4E252CFE.4070408@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jul 19, 2011, at 2:06 AM, Matt Evans wrote:

> On 19/07/11 16:59, Kumar Gala wrote:
>> 
>> On Jul 18, 2011, at 9:13 PM, Matt Evans wrote:
>> 
>>> An implementation of a code generator for BPF programs to speed up packet
>>> filtering on PPC64, inspired by Eric Dumazet's x86-64 version.
>>> 
>>> Filter code is generated as an ABI-compliant function in module_alloc()'d mem
>>> with stackframe & prologue/epilogue generated if required (simple filters don't
>>> need anything more than an li/blr).  The filter's local variables, M[], live in
>>> registers.  Supports all BPF opcodes, although "complicated" loads from negative
>>> packet offsets (e.g. SKF_LL_OFF) are not yet supported.
>>> 
>>> There are a couple of further optimisations left for future work; many-pass
>>> assembly with branch-reach reduction and a register allocator to push M[]
>>> variables into volatile registers would improve the code quality further.
>>> 
>>> This currently supports big-endian 64-bit PowerPC only (but is fairly simple
>>> to port to PPC32 or LE!).
>>> 
>>> Enabled in the same way as x86-64:
>>> 
>>> 	echo 1 > /proc/sys/net/core/bpf_jit_enable
>>> 
>>> Or, enabled with extra debug output:
>>> 
>>> 	echo 2 > /proc/sys/net/core/bpf_jit_enable
>>> 
>>> Signed-off-by: Matt Evans <matt@ozlabs.org>
>>> ---
>>> 
>>> V2: Removed some cut/paste woe in setting SEEN_X even on writes.
>>>   Merci for le review, Eric!
>>> 
>>> arch/powerpc/Kconfig                  |    1 +
>>> arch/powerpc/Makefile                 |    3 +-
>>> arch/powerpc/include/asm/ppc-opcode.h |   40 ++
>>> arch/powerpc/net/Makefile             |    4 +
>>> arch/powerpc/net/bpf_jit.S            |  138 +++++++
>> 
>> can we rename to bpf_jit_64.S, since this doesn't work on PPC32.
>> 
>>> arch/powerpc/net/bpf_jit.h            |  227 +++++++++++
>>> arch/powerpc/net/bpf_jit_comp.c       |  690 +++++++++++++++++++++++++++++++++
>> 
>> same here, or split between bpf_jit_comp.c (shared between ppc32 & ppc64) and
>> bpf_jit_comp_64.c
> 
> A reasonable suggestion -- bpf_jit_64.S certainly.  I think it may not be worth
> splitting bpf_jit_comp.c until we support both tho?  (I'm thinking
> bpf_jit_comp_{32,64}.c would just house the stackframe generation code which is
> the main difference, plus compile-time switched macros for the odd LD vs LWZ.)

If its most 64-bit specific than just go with bpf_jit_comp_64.c for now.  We can refactor later.

> 
> Sorry it's not 32bit-friendly just yet (I knew you'd ask, hehe), I've postponed
> that for when I get a mo :-)

:)

