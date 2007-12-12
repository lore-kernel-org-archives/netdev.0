From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET]: Fix Ooops of napi net_rx_action.
Date: Wed, 12 Dec 2007 07:12:54 -0800 (PST)
Message-ID: <20071212.071254.180816076.davem@davemloft.net>
References: <36D9DB17C6DE9E40B059440DB8D95F5203F82FC3@orsmsx418.amr.corp.intel.com>
	<b25c3fa70712111612o16a62b49g6709aa728f31e27a@mail.gmail.com>
	<36D9DB17C6DE9E40B059440DB8D95F5203FBAF94@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joonwpark81@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	auke-jan.h.kok@intel.com
To: jesse.brandeburg@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757422AbXLLPNS@vger.kernel.org>
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5203FBAF94@orsmsx418.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Tue, 11 Dec 2007 16:38:37 -0800

> @@ -3933,6 +3933,10 @@ quit_polling:
>                         e1000_set_itr(adapter);
>                 netif_rx_complete(poll_dev, napi);
>                 e1000_irq_enable(adapter);
> +               if (work_done == weight)
> +                       return work_done - 1;
> +               else
> +                       return work_done;

Don't do this.

If you processed "weight" worth of packets, return that
exact value and do not netif_rx_complete() and do not
re-enable interrupts.

That is the only correct fix.
