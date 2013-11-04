From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 02/13] driver: net: remove unnecessary skb
 NULL check before calling dev_kfree_skb_irq
Date: Mon, 04 Nov 2013 15:12:30 -0500 (EST)
Message-ID: <20131104.151230.1978898006990867916.davem@davemloft.net>
References: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
	<1383400074-30555-3-git-send-email-govindarajulu90@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, IvDoorn@gmail.com, sbhatewara@vmware.com,
	samuel@sortiz.org, chas@cmf.nrl.navy.mil, roland@kernel.org,
	isdn@linux-pingi.de, jcliburn@gmail.com, benve@cisco.com,
	ssujith@cisco.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, shahed.shaikh@qlogic.com,
	joe@perches.com, apw@canonical.com
To: govindarajulu90@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383400074-30555-3-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Date: Sat,  2 Nov 2013 19:17:43 +0530

> @@ -1030,10 +1030,8 @@ static void ni65_xmit_intr(struct net_device *dev,int csr0)
>  		}
>  
>  #ifdef XMT_VIA_SKB
> -		if(p->tmd_skb[p->tmdlast]) {
> -			 dev_kfree_skb_irq(p->tmd_skb[p->tmdlast]);
> -			 p->tmd_skb[p->tmdlast] = NULL;
> -		}
> +		 dev_kfree_skb_irq(p->tmd_skb[p->tmdlast]);
> +		 p->tmd_skb[p->tmdlast] = NULL;
>  #endif

I absolutely disagree with this kind of change.

There is a non-trivial cost for NULL'ing out that array entry
unconditionally.  It's a dirtied cache line and this is in the
fast path of TX SKB reclaim of this driver.

You've made several changes of this kind.

And it sort-of shows that the places that do check for NULL,
are getting something in return for that test, namely avoidance
of an unnecessary cpu store in the fast path of the driver.

I'm throwing away this series, sorry.
