From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 2/2] Renesas Ethernet AVB PTP clock driver
Date: Thu, 11 Jun 2015 00:24:25 -0700 (PDT)
Message-ID: <20150611.002425.1698330124707614277.davem@davemloft.net>
References: <2950738.iaDWZVkjG3@wasted.cogentembedded.com>
	<20150611.001455.377939359927165224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	linux-sh@vger.kernel.org, masaru.nagai.vx@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20150611.001455.377939359927165224.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 11 Jun 2015 00:14:55 -0700 (PDT)

> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Date: Thu, 11 Jun 2015 01:02:30 +0300
> 
>> Ethernet AVB device includes the gPTP  timer, so we can implement a PTP clock
>> driver.  We're doing that in a separate file, with  the main Ethernet driver
>> calling the PTP driver's [de]initialization and interrupt handler functions.
>> Unfortunately, the clock seems tightly coupled with the AVB-DMAC, so when that
>> one leaves the operation mode, we have to unregister the PTP clock... :-(
>> 
>> Based on the original patches by Masaru Nagai.
>> 
>> Signed-off-by: Masaru Nagai <masaru.nagai.vx@renesas.com>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> Applied.

I had to fix up this patch because:

obj-$(CONFIG_RAVB) += ravb_main.o ravb_ptp.o

Doesn't do what you want it to for the modular case.

You instead need to say something like:

ravb-objs := ravb_main.o ravb_ptp.o

obj-$(CONFIG_RAVB) += ravb.o

and that's how I fixed up this commit before pushing it out.

