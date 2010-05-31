From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: don't xt_jumpstack_alloc twice in
 xt_register_table
Date: Mon, 31 May 2010 15:19:31 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1005311519160.25402@obet.zrqbmnf.qr>
References: <1275303998-2435-1-git-send-email-dfeng@redhat.com> <alpine.LSU.2.01.1005311350580.31799@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Xiaotian Feng <dfeng@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1005311350580.31799@obet.zrqbmnf.qr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2010-05-31 13:51, Jan Engelhardt wrote:
>On Monday 2010-05-31 13:06, Xiaotian Feng wrote:
>
>>In xt_register_table, xt_jumpstack_alloc is called first, later
>>xt_replace_table is used. But in xt_replace_table, xt_jumpstack_alloc
>>will be used again. Then the memory allocated by previous xt_jumpstack_alloc
>>will be leaked. We can simply remove the previous xt_jumpstack_alloc because
>>there aren't any users of newinfo between xt_jumpstack_alloc and
>>xt_replace_table.
>
>Indeed that seems to be so.

Acked-By: Jan Engelhardt <jengelh@medozas.de>

>
>>diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
>>index 445de70..47b1e79 100644
>>--- a/net/netfilter/x_tables.c
>>+++ b/net/netfilter/x_tables.c
>>@@ -844,10 +844,6 @@ struct xt_table *xt_register_table(struct net *net,
>> 	struct xt_table_info *private;
>> 	struct xt_table *t, *table;
>> 
>>-	ret = xt_jumpstack_alloc(newinfo);
>>-	if (ret < 0)
>>-		return ERR_PTR(ret);
>>-
>> 	/* Don't add one object to multiple lists. */
>> 	table = kmemdup(input_table, sizeof(struct xt_table), GFP_KERNEL);
>> 	if (!table) {
>--
>To unsubscribe from this list: send the line "unsubscribe netfilter" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
