From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] sysctl: fix min/max handling in
 __do_proc_doulongvec_minmax()
Date: Mon, 4 Oct 2010 11:09:15 +0800
Message-ID: <20101004030915.GC5189@cr0.nay.redhat.com>
References: <1286025469.2582.1806.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Robin Holt <holt@sgi.com>, Willy Tarreau <w@1wt.eu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1286025469.2582.1806.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 02, 2010 at 03:17:49PM +0200, Eric Dumazet wrote:
>When proc_doulongvec_minmax() is used with an array of longs,
>and no min/max check requested (.extra1 or .extra2 being NULL), we
>dereference a NULL pointer for the second element of the array.
>
>Noticed while doing some changes in network stack for the "16TB problem"
>
>Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>---
> kernel/sysctl.c |    3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
>
>diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>index f88552c..4fba86d 100644
>--- a/kernel/sysctl.c
>+++ b/kernel/sysctl.c
>@@ -2500,7 +2500,8 @@ static int __do_proc_doulongvec_minmax(void *data, struct ctl_table *table, int
> 				break;
> 			if (neg)
> 				continue;
>-			if ((min && val < *min) || (max && val > *max))
>+			if ((table->extra1 && val < *min) ||
>+			    (table->extra2 && val > *max))
> 				continue;


Yes? This is wrong for me, min and max are pointers to ->extra{1,2},
they are increased within the for loop, you are only checking the
the pointer to the first element of ->extra{1,2}.
