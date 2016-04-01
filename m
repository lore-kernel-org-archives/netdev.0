From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH 6/6] ppc: ebpf/jit: Implement JIT compiler for extended
 BPF
Date: Fri, 01 Apr 2016 20:34:57 +0200
Message-ID: <56FEBF51.7090608@iogearbox.net>
References: <cover.1459504222.git.naveen.n.rao@linux.vnet.ibm.com> <b58a289b51bbce73f8539290b721a5d461b7cebb.1459504224.git.naveen.n.rao@linux.vnet.ibm.com> <56FEB9AD.2080401@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss@buserror.net, Matt Evans <matt@ozlabs.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
	"Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56FEB9AD.2080401@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/01/2016 08:10 PM, Alexei Starovoitov wrote:
> On 4/1/16 2:58 AM, Naveen N. Rao wrote:
>> PPC64 eBPF JIT compiler. Works for both ABIv1 and ABIv2.
>>
>> Enable with:
>> echo 1 > /proc/sys/net/core/bpf_jit_enable
>> or
>> echo 2 > /proc/sys/net/core/bpf_jit_enable
>>
>> ... to see the generated JIT code. This can further be processed with
>> tools/net/bpf_jit_disasm.
>>
>> With CONFIG_TEST_BPF=m and 'modprobe test_bpf':
>> test_bpf: Summary: 291 PASSED, 0 FAILED, [234/283 JIT'ed]
>>
>> ... on both ppc64 BE and LE.
>>
>> The details of the approach are documented through various comments in
>> the code, as are the TODOs. Some of the prominent TODOs include
>> implementing BPF tail calls and skb loads.
>>
>> Cc: Matt Evans <matt@ozlabs.org>
>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>> Cc: Paul Mackerras <paulus@samba.org>
>> Cc: Alexei Starovoitov <ast@fb.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
>> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
>> ---
>>   arch/powerpc/include/asm/ppc-opcode.h |  19 +-
>>   arch/powerpc/net/Makefile             |   4 +
>>   arch/powerpc/net/bpf_jit.h            |  66 ++-
>>   arch/powerpc/net/bpf_jit64.h          |  58 +++
>>   arch/powerpc/net/bpf_jit_comp64.c     | 828 ++++++++++++++++++++++++++++++++++
>>   5 files changed, 973 insertions(+), 2 deletions(-)
>>   create mode 100644 arch/powerpc/net/bpf_jit64.h
>>   create mode 100644 arch/powerpc/net/bpf_jit_comp64.c
> ...
>> -#ifdef CONFIG_PPC64
>> +#if defined(CONFIG_PPC64) && (!defined(_CALL_ELF) || _CALL_ELF != 2)
>
> impressive stuff!

+1, awesome to see another one!

> Everything nicely documented. Could you add few words for the above
> condition as well ?
> Or may be a new macro, since it occurs many times?
> What are these _CALL_ELF == 2 and != 2 conditions mean? ppc ABIs ?
> Will there ever be v3 ?

Minor TODO would also be to convert to use bpf_jit_binary_alloc() and
bpf_jit_binary_free() API for the image, which is done by other eBPF
jits, too.

> So far most of the bpf jits were going via net-next tree, but if
> in this case no changes to the core is necessary then I guess it's fine
> to do it via powerpc tree. What's your plan?
>
