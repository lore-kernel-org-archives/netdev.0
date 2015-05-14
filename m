From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] test_bpf: fix sparse warnings
Date: Thu, 14 May 2015 18:10:31 +0200
Message-ID: <5554C8F7.5080002@iogearbox.net>
References: <1431574839-7099-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44191 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964872AbbENQKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 12:10:40 -0400
In-Reply-To: <1431574839-7099-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/14/2015 05:40 AM, Alexei Starovoitov wrote:
> From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
>
> Fix several sparse warnings like:
> lib/test_bpf.c:1824:25: sparse: constant 4294967295 is so big it is long
> lib/test_bpf.c:1878:25: sparse: constant 0x0000ffffffff0000 is so big it is long
>
> Fixes: cffc642d93f9 ("test_bpf: add 173 new testcases for eBPF")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>   lib/test_bpf.c |  122 ++++++++++++++++++++++++++++----------------------------
>   1 file changed, 61 insertions(+), 61 deletions(-)
>
...
>   	{
>   		"ALU_MOV_K: 0x0000ffffffff0000 = 0x00000000ffffffff",
>   		.u.insns_int = {
> -			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
> -			BPF_LD_IMM64(R3, 0x00000000ffffffff),
> +			BPF_LD_IMM64(R2, 0x0000ffffffff0000LL),
> +			BPF_LD_IMM64(R3, 0x00000000ffffffffLL),

Should have been ULL, no? Anyway, the BPF_LD_IMM64() macro will cast it
correctly anyway.

Other than that:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
