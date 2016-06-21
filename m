From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH] ppc: Fix BPF JIT for ABIv2
Date: Tue, 21 Jun 2016 08:45:59 -0700
Message-ID: <57696137.5020408@fb.com>
References: <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <3rWKtT2tSrz9t2G@ozlabs.org> <20160617130042.GO3516@indiana.gru.redhat.com>
 <20160619174914.GC8886@naverao1-tp.localdomain>
 <20160620185620.GD3516@indiana.gru.redhat.com>
 <20160621085807.GE8886@naverao1-tp.localdomain>
 <1466507748.18876.3.camel@ellerman.id.au>
 <20160621144725.GH3516@indiana.gru.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	<linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<netdev@vger.kernel.org>, Matt Evans <matt@ozlabs.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	"Paul Mackerras" <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Ananth N Mavinakayanahalli" <ananth@in.ibm.com>
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	Michael Ellerman <mpe@ellerman.id.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160621144725.GH3516@indiana.gru.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/21/16 7:47 AM, Thadeu Lima de Souza Cascardo wrote:
>>>
>>> The calling convention is different with ABIv2 and so we'll need changes
>>> in bpf_slow_path_common() and sk_negative_common().
>>
>> How big would those changes be? Do we know?
>>
>> How come no one reported this was broken previously? This is the first I've
>> heard of it being broken.
>>
>
> I just heard of it less than two weeks ago, and only could investigate it last
> week, when I realized mainline was also affected.
>
> It looks like the little-endian support for classic JIT were done before the
> conversion to ABIv2. And as JIT is disabled by default, no one seems to have
> exercised it.

it's not a surprise unfortunately. The JITs that were written before
test_bpf.ko was developed were missing corner cases. Typical tcpdump
would be fine, but fragmented packets, negative offsets and
out-out-bounds wouldn't be handled correctly.
I'd suggest to validate the stable backport with test_bpf as well.
