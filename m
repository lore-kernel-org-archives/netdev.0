From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] sh: add missing fpscr_values
Date: Wed, 02 Apr 2014 09:04:30 +0200
Message-ID: <533BB67E.4030803@redhat.com>
References: <1396407244-26771-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Paul Mundt <lethal@linux-sh.org>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-sh@vger.kernel.org, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1396407244-26771-1-git-send-email-ast@plumgrid.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/02/2014 04:54 AM, Alexei Starovoitov wrote:
> GCC on SuperH for the following program:
> int foo(int i)
> {
> 	static const void *table[2] = {
> 		[0] = &&label1,
> 		[1] = &&label2,
> 	};
> 	goto *table[i & 1];
>
> 	label1:
> 		return 1;
> 	label2:
> 		return 2;
> }
> generates code:
> 	mov.l   .L9,r1
> 	mov     #1,r0
> 	rts
> 	lds.l   @r1+,fpscr
> .L9:
> 	.long   __fpscr_values+4
>
> so kernel has to provide body of fpscr_values just like glibc does
>
> Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF interpreter's instruction set")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
