From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: Re: [PATCH] drivers/net: spidernet driver on Celleb
Date: Thu, 14 Dec 2006 20:02:45 +0900 (JST)
Message-ID: <200612141102.kBEB2kon010247@toshiba.co.jp>
References: <20061212122450.GA30466@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jim@jklewis.com, linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: hch@infradead.org
In-Reply-To: <20061212122450.GA30466@infradead.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Christoph-san,

Thanks for your comments.

>On Tue, Dec 12, 2006 at 02:25:50PM +0900, Ishizaki Kou wrote:
>> 
>> Following are the changes.
>> -This patch enables auto-negotiation.
>> -Loading firmware is done when spidernet_open() is called.
>> -And this patch adds other several small changes for Celleb. 
>
>This should be split into three separate patches, sent as a patch
>series.

We are now working to separeting the patch. We'll send later.

>> -/* outside loopback mode: ETOMOD signal dont matter, not connected */
>> -#define SPIDER_NET_OPMODE_VALUE     0x00000063
>> +/* ETOMOD signal is brought to PHY reset. bit2 must be 1 in Celleb */
>> +#define SPIDER_NET_OPMODE_VALUE     0x00000067
>
>Is it okay to simple change this value for the ibm blades?

Sorry, we didn't test on ibm blades, because we don't have one.
We hope to develop together so that the driver works on both platform.

>> +static int is1000 = 1;
>
>This should be in struct spider_net_card instead of a global flag.

We'll move it in struct spider_net_card.

>>      case SPIDER_NET_GTMFLLINT:
>> -        if (netif_msg_intr(card) && net_ratelimit())
>> -            pr_err("Spider TX RAM full\n");
>> +        /* if (netif_msg_intr(card) && net_ratelimit())
>> +            pr_err("Spider TX RAM full\n"); */
>
>Either this should be kept or removed entirely.  In the latter case you
>need a good description why it's removed in the patch header.

We'll remove it entirely.

GTMFLLINT occures frequently when we use 100M HUB. We didn't find any
bad influence by this interrupt so far, so we removed the output.

>> +
>> +    spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
>> +                         spider_net_read_reg(card, SPIDER_NET_GMACOPEMD) | 0x4);
>
>Please make sure this doesn't overflow the 80 characters per line limit.

We'll correct it. 

>> +static int spider_net_init_firmware(struct spider_net_card *);
>
>Random forward declarations in the middle of the file aren't very nice.
>If you really need them put them at the beggining of the file, but it would
>be even better if you moved spider_net_init_firmware further up in the
>file so we wouldn't need the forward-declaration at all.

We'll move some functions.

>> +    if (card->phy.def->phy_id)
>> +        mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
>> +    else
>> +        pr_err("No phy is available\n");
>
>What is this idiom about?  Is not having a phy a fatal error in which case
>we should abort here, or is it tolerable in which case pr_err is too much.

Checking phy_id is not required here, so we'll change to call
mod_timer() simply.

>> +static void spider_net_init_card(struct spider_net_card *);
>
>Same comment above forward declarations as above.

Thank you,
Kou Ishizaki
Toshiba
