From: Daniel Wagner <daniel.wagner@bmw-carit.de>
Subject: Re: [PATCH v2 net-next 0/12] bpf: map pre-alloc
Date: Tue, 8 Mar 2016 10:13:12 +0100
Message-ID: <56DE97A8.1050309@bmw-carit.de>
References: <1457416641-306326-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457416641-306326-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexei,

On 03/08/2016 06:57 AM, Alexei Starovoitov wrote:
> v1->v2:
> . fix few issues spotted by Daniel
> . converted stackmap into pre-allocation as well
> . added a workaround for lockdep false positive
> . added pcpu_freelist_populate to be used by hashmap and stackmap
> 
> this path set switches bpf hash map to use pre-allocation by default
> and introduces BPF_F_NO_PREALLOC flag to keep old behavior for cases
> where full map pre-allocation is too memory expensive.
> 
> Some time back Daniel Wagner reported crashes when bpf hash map is
> used to compute time intervals between preempt_disable->preempt_enable
> and recently Tom Zanussi reported a dead lock in iovisor/bcc/funccount
> tool if it's used to count the number of invocations of kernel
> '*spin*' functions. Both problems are due to the recursive use of
> slub and can only be solved by pre-allocating all map elements.

I gave it a short spin and lathist sample works just fine.

cheers,
daniel
