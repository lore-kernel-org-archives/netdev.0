From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 1/2] r8152: add
 RTL8152_EARLY_AGG_TIMEOUT_SUPER
Date: Thu, 13 Mar 2014 09:28:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6DC810@AcuExch.aculab.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
 <1394681648-7321-1-git-send-email-albertk@realtek.com>
 <1394681648-7321-2-git-send-email-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "nic_swsd@realtek.com" <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: 'Hayes Wang' <hayeswang@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394681648-7321-2-git-send-email-albertk@realtek.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang
> For slow CPU, the frequent bulk transfer would cause poor throughput.
> One solution is to increase the timeout of the aggregation. It let
> the hw could complete the bulk transfer later and fill more packets
> into the buffer. Besides, it could reduce the frequency of the bulk
> transfer efficiently and improve the performance.
> 
> However, the optimization value of the timeout depends on the
> capability of the hardware, especially the CPU. For example, according
> to the experiment, the timeout 164 us is better than the default
> value for the chromebook with the ARM CPU.

The best value probably depends on the workload as well as the
cpu speed.
I wonder if a sane algorithm for dynamically setting this value exists.
It really needs a CBU (crystal ball unit), but working ones are
difficult to come by.

Passing the buck to the 'user' is rather a cop-out (but we all do it).

> Now add RTL8152_EARLY_AGG_TIMEOUT_SUPER to let someone could choose
> desired timeout value if he wants to get the best performance.
...
>  /* USB_RX_EARLY_AGG */
> -#define EARLY_AGG_SUPPER	0x0e832981
> +#define EARLY_AGG_SUPER	((((rx_buf_sz - 1522) / 4) << 16) | \
> +	(u32)(CONFIG_RTL8152_EARLY_AGG_TIMEOUT_SUPER <= 0 ? 0x2981 : \
> +	((CONFIG_RTL8152_EARLY_AGG_TIMEOUT_SUPER * 125) < 0xffff ? \
> +	CONFIG_RTL8152_EARLY_AGG_TIMEOUT_SUPER * 125 : 0xffff)))

The 0x2981 would be better written as (85 * 125).
But maybe replace with something like:
	min((CONFIG_RTL8152_EARLY_AGG_TIMEOUT_SUPER <= 0 ? 85 :
		CONFIG_RTL8152_EARLY_AGG_TIMEOUT_SUPER) * 125u, 0xffffu)

	David
