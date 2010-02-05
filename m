From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: Re: [PATCH 11/13] net: irda: use seq_list_foo() helpers
Date: Fri, 05 Feb 2010 13:46:39 +0200
Message-ID: <4B6C051F.3080702@gmail.com>
References: <4B6B77FE.5000104@cn.fujitsu.com> <4B6B78AD.1030809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B6B78AD.1030809@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/05/2010 03:47 AM, Li Zefan wrote:
[...]
>   /* Return entry after v, and increment pos */
> @@ -1148,14 +1137,7 @@ static void *irlan_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>   {
>   	struct list_head *nxt;

you should remove nxt declaration.

> -	++*pos;
> -	if (v == SEQ_START_TOKEN)
> -		nxt = irlans.next;
> -	else
> -		nxt = ((struct irlan_cb *)v)->dev_list.next;
> -
> -	return (nxt ==&irlans) ? NULL
> -		: list_entry(nxt, struct irlan_cb, dev_list);
> +	return seq_list_next(v,&irlans, pos);
>   }
[...]
