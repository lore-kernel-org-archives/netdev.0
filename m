From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v4] ethernet/arc/arc_emac - Add new driver
Date: Mon, 17 Jun 2013 09:03:50 +0000
Message-ID: <4881796E12491D4BB15146FE0209CE643F5EC000@DE02WEMBXB.internal.synopsys.com>
References: <1371327652-9368-1-git-send-email-abrodkin@synopsys.com>
	 <1371328671.2117.6.camel@joe-AO722>
	 <4881796E12491D4BB15146FE0209CE643F5E7779@DE02WEMBXB.internal.synopsys.com>
 <1371368491.2116.0.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"Vineet Gupta" <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	"Paul Gortmaker" <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/16/2013 11:41 AM, Joe Perches wrote:
> On Sat, 2013-06-15 at 20:47 +0000, Alexey Brodkin wrote:
>> On 06/16/2013 12:37 AM, Joe Perches wrote:
>>> On Sun, 2013-06-16 at 00:20 +0400, Alexey Brodkin wrote:
> []
>>>> +static int arc_emac_rx(struct net_device *ndev, int budget)
>>> []
>>>> +		/* Prepare the BD for next cycle */
>>>> +		rx_buff->skb = netdev_alloc_skb_ip_align(ndev, buflen);
>>>> +		if (unlikely(!rx_buff->skb)) {
>>>> +			if (net_ratelimit())
>>>> +				netdev_err(ndev, "cannot allocate skb\n");
>>>
>>> Unnecessary OOM message, might as well remove it.
>>> rx_dropped gives the same info.
>>
>> With all those error messages I wanted to make life easier (especially
>> for me) if errors appear. User will immediately know where problem
>> happened. Indeed "rx_dropped" (when it is used only once in driver) may
>> show where issue happened, but if later at some point "rx_dropped" will
>> be incremented in other locations then user won't understand immediately
>> where error happened.
>
> Alloc errors emit a dump_stack() already so this is redundant.

Makes sense. Will remove this comment.

-Alexey
