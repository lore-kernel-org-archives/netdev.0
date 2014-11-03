From: Philippe Bergheaud <felix@linux.vnet.ibm.com>
Subject: Re: [PATCH] PPC: bpf_jit_comp: add SKF_AD_PKTTYPE instruction
Date: Mon, 03 Nov 2014 16:45:10 +0100
Message-ID: <5457A306.4040302@linux.vnet.ibm.com>
References: <1414351406-4122-1-git-send-email-kda@linux-powerpc.org> <CAOJe8K0t3G-bHm_24GjrTp9mmKnYZS1_bdGgrwQBLjC_s5is6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Matt Evans <matt@ozlabs.org>, mpe@ellerman.id.au
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:56391 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227AbaKCPnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 10:43:17 -0500
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <felix@linux.vnet.ibm.com>;
	Mon, 3 Nov 2014 15:43:15 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 19A3F1B0805F
	for <netdev@vger.kernel.org>; Mon,  3 Nov 2014 15:43:17 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sA3FhBqA6095160
	for <netdev@vger.kernel.org>; Mon, 3 Nov 2014 15:43:11 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sA3FhAWP009458
	for <netdev@vger.kernel.org>; Mon, 3 Nov 2014 08:43:11 -0700
In-Reply-To: <CAOJe8K0t3G-bHm_24GjrTp9mmKnYZS1_bdGgrwQBLjC_s5is6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis Kirjanov wrote:
> Any feedback from PPC folks?

I have reviewed the patch and it looks fine to me.
I have tested successfuly on ppc64le.
I could not test it on ppc64.

Philippe

> On 10/26/14, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> 
>>Cc: Matt Evans <matt@ozlabs.org>
>>Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>>---
>> arch/powerpc/include/asm/ppc-opcode.h | 1 +
>> arch/powerpc/net/bpf_jit.h            | 7 +++++++
>> arch/powerpc/net/bpf_jit_comp.c       | 5 +++++
>> 3 files changed, 13 insertions(+)
>>
>>diff --git a/arch/powerpc/include/asm/ppc-opcode.h
>>b/arch/powerpc/include/asm/ppc-opcode.h
>>index 6f85362..1a52877 100644
>>--- a/arch/powerpc/include/asm/ppc-opcode.h
>>+++ b/arch/powerpc/include/asm/ppc-opcode.h
>>@@ -204,6 +204,7 @@
>> #define PPC_INST_ERATSX_DOT		0x7c000127
>>
>> /* Misc instructions for BPF compiler */
>>+#define PPC_INST_LBZ			0x88000000
>> #define PPC_INST_LD			0xe8000000
>> #define PPC_INST_LHZ			0xa0000000
>> #define PPC_INST_LHBRX			0x7c00062c
>>diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
>>index 9aee27c..c406aa9 100644
>>--- a/arch/powerpc/net/bpf_jit.h
>>+++ b/arch/powerpc/net/bpf_jit.h
>>@@ -87,6 +87,9 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
>> #define PPC_STD(r, base, i)	EMIT(PPC_INST_STD | ___PPC_RS(r) |	      \
>> 				     ___PPC_RA(base) | ((i) & 0xfffc))
>>
>>+
>>+#define PPC_LBZ(r, base, i)	EMIT(PPC_INST_LBZ | ___PPC_RT(r) |	      \
>>+				     ___PPC_RA(base) | IMM_L(i))
>> #define PPC_LD(r, base, i)	EMIT(PPC_INST_LD | ___PPC_RT(r) |	      \
>> 				     ___PPC_RA(base) | IMM_L(i))
>> #define PPC_LWZ(r, base, i)	EMIT(PPC_INST_LWZ | ___PPC_RT(r) |	      \
>>@@ -96,6 +99,10 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
>> #define PPC_LHBRX(r, base, b)	EMIT(PPC_INST_LHBRX | ___PPC_RT(r) |	      \
>> 				     ___PPC_RA(base) | ___PPC_RB(b))
>> /* Convenience helpers for the above with 'far' offsets: */
>>+#define PPC_LBZ_OFFS(r, base, i) do { if ((i) < 32768) PPC_LBZ(r, base, i);
>>  \
>>+		else {	PPC_ADDIS(r, base, IMM_HA(i));			      \
>>+			PPC_LBZ(r, r, IMM_L(i)); } } while(0)
>>+
>> #define PPC_LD_OFFS(r, base, i) do { if ((i) < 32768) PPC_LD(r, base, i);
>>  \
>> 		else {	PPC_ADDIS(r, base, IMM_HA(i));			      \
>> 			PPC_LD(r, r, IMM_L(i)); } } while(0)
>>diff --git a/arch/powerpc/net/bpf_jit_comp.c
>>b/arch/powerpc/net/bpf_jit_comp.c
>>index cbae2df..d110e28 100644
>>--- a/arch/powerpc/net/bpf_jit_comp.c
>>+++ b/arch/powerpc/net/bpf_jit_comp.c
>>@@ -407,6 +407,11 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32
>>*image,
>> 			PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
>> 							  queue_mapping));
>> 			break;
>>+		case BPF_ANC | SKF_AD_PKTTYPE:
>>+			PPC_LBZ_OFFS(r_A, r_skb, PKT_TYPE_OFFSET());
>>+			PPC_ANDI(r_A, r_A, PKT_TYPE_MAX);
>>+			PPC_SRWI(r_A, r_A, 5);
>>+			break;
>> 		case BPF_ANC | SKF_AD_CPU:
>> #ifdef CONFIG_SMP
>> 			/*
>>--
>>2.1.0
>>
>>
> 
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
