From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6.11 PKT_SCHED]: ipt action: add back pskb_expand_head
 call
Date: Fri, 04 Feb 2005 05:09:39 +0100
Message-ID: <4202F583.1040601@trash.net>
References: <4202E7BE.6050606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <4202E7BE.6050606@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:

> Hi Dave,
>
> Jamal asked me to add back the call to pskb_expand_head before 2.6.11.
> This fixes a regression caused by my tc action cleanup patches, the
> tc actions most not replace packets, so it must prevent netfilter from
> doing so.


I forgot the Signed-off-by line, sorry:

Signed-off-by: Patrick McHardy <kaber@trash.net>

>------------------------------------------------------------------------
>
>===== net/sched/ipt.c 1.13 vs edited =====
>--- 1.13/net/sched/ipt.c	2005-01-14 05:41:07 +01:00
>+++ edited/net/sched/ipt.c	2005-02-04 04:06:45 +01:00
>@@ -207,6 +207,11 @@
> 	struct tcf_ipt *p = PRIV(a, ipt);
> 	struct sk_buff *skb = *pskb;
> 
>+	if (skb_cloned(skb)) {
>+		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
>+			return TC_ACT_UNSPEC;
>+	}
>+
> 	spin_lock(&p->lock);
> 
> 	p->tm.lastuse = jiffies;
>  
>
