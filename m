From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sh: add missing fpscr_values
Date: Wed, 02 Apr 2014 08:47:13 -0400 (EDT)
Message-ID: <20140402.084713.204716153605145333.davem@davemloft.net>
References: <1396407244-26771-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, dborkman@redhat.com,
	lethal@linux-sh.org, fengguang.wu@intel.com,
	linux-sh@vger.kernel.org, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1396407244-26771-1-git-send-email-ast@plumgrid.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue,  1 Apr 2014 19:54:04 -0700

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

You guys really need to just fix the compiler, sorry.
