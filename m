From: Gertjan van Wingerde <gwingerde@gmail.com>
Subject: Re: [PATCH 1/11] rt2x00: use ether_addr_equal_64bits
Date: Tue, 31 Dec 2013 17:44:03 +0100
Message-ID: <DF2F19A7-DC12-44CE-8488-9BCC92A23D84@gmail.com>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr> <1388427307-8691-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Ivo van Doorn <IvDoorn@gmail.com>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"users@rt2x00.serialmonkey.com" <users@rt2x00.serialmonkey.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388427307-8691-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Sent from my iPad

> On 30 dec. 2013, at 19:14, Julia Lawall <Julia.Lawall@lip6.fr> wrote:
> 
> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Ether_addr_equal_64bits is more efficient than ether_addr_equal, and can be
> used when each argument is an array within a structure that contains at
> least two bytes of data beyond the array.
> 
> The structures involved are:
> ieee80211_bar defined in include/linux/ieee80211.h and
> rt2x00_bar_list_entry defined in drivers/net/wireless/rt2x00/rt2x00.h.
> 
> This was done using Coccinelle (http://coccinelle.lip6.fr/).
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Acked-by: Gertjan van Wingerde <gwingerde@gmail.com>

> 
> ---
> The semantic patch used is rather long and can be found in message 0 of
> this patch series.
> 
> drivers/net/wireless/rt2x00/rt2x00dev.c |    4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
> index 00c3fae..2bde672 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00dev.c
> +++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
> @@ -565,10 +565,10 @@ static void rt2x00lib_rxdone_check_ba(struct rt2x00_dev *rt2x00dev,
> 
> #undef TID_CHECK
> 
> -        if (!ether_addr_equal(ba->ra, entry->ta))
> +        if (!ether_addr_equal_64bits(ba->ra, entry->ta))
>            continue;
> 
> -        if (!ether_addr_equal(ba->ta, entry->ra))
> +        if (!ether_addr_equal_64bits(ba->ta, entry->ra))
>            continue;
> 
>        /* Mark BAR since we received the according BA */
> 
