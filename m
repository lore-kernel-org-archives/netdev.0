From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: Synopsys Ethernet QoS
Date: Thu, 15 Dec 2016 13:05:35 +0100
Message-ID: <d9fc4a14-2628-b07d-7024-16c7890f5bcc@axis.com>
References: <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
 <20161209.104152.1969880574279771010.davem@davemloft.net>
 <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
 <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
 <CAHp75VfT9B3O5jU0eHoKtgYc48K2ZjCQ-g9ZQ9nX1Hew6tz-zw@mail.gmail.com>
 <556353b7-c847-7549-626d-3c324063647e@gmail.com>
 <f5357ea2-a295-ab08-046e-f8b8f6ca4344@synopsys.com>
 <1d445ec1-deb8-6e36-39c4-6813c446095f@axis.com>
 <73bf8cb4-5685-2db6-529c-1de99b1fd358@st.com>
 <99424968-ad8f-fec6-ebcf-ab7b19ee5486@axis.com> <20161214125735.GA19542@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>,
        David Miller <davem@davemloft.net>, <larper@axis.com>,
        <rabinv@axis.com>, netdev <netdev@vger.kernel.org>,
        <CARLOS.PALMINHA@synopsys.com>, <Jie.Deng1@synopsys.com>,
        Stephen Warren <swarren@nvidia.com>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:43691 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbcLOMPK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 07:15:10 -0500
In-Reply-To: <20161214125735.GA19542@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/2016 01:57 PM, Pavel Machek wrote:
> Hi!
>
>> So if there is a long time before handling interrupts,
>> I guess that it makes sense that one stream could
>> get an advantage in the net scheduler.
>>
>> If I find the time, and if no one beats me to it, I will try to replace
>> the normal timers with HR timers + a smaller default timeout.
>>
> Can you try something like this? Highres timers will be needed, too,
> but this fixes the logic problem.

Hello Pavel

I tried your patch, but unfortunately I get a tx queue timeout.
After that, I cannot ping.

[   22.075782] ------------[ cut here ]------------
[   22.080430] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:316 dev_watchdog+0x240/0x258
[   22.088704] NETDEV WATCHDOG: eth0 (stmmaceth): transmit queue 0 timed out
[   22.095491] Modules linked in:
[   22.098552] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.9.0-axis3-devel #126
[   22.105592] Hardware name: Axis ARTPEC-6 Platform
[   22.110301] [<80110568>] (unwind_backtrace) from [<8010c2bc>] (show_stack+0x18/0x1c)
[   22.118043] [<8010c2bc>] (show_stack) from [<80433544>] (dump_stack+0x80/0xa0)
[   22.125264] [<80433544>] (dump_stack) from [<8011f9f0>] (__warn+0xe0/0x10c)
[   22.132221] [<8011f9f0>] (__warn) from [<8011fadc>] (warn_slowpath_fmt+0x40/0x50)
[   22.139700] [<8011fadc>] (warn_slowpath_fmt) from [<805e626c>] (dev_watchdog+0x240/0x258)
[   22.147875] [<805e626c>] (dev_watchdog) from [<801826c8>] (call_timer_fn+0x44/0x208)
[   22.155613] [<801826c8>] (call_timer_fn) from [<80182934>] (expire_timers+0xa8/0x15c)
[   22.163437] [<80182934>] (expire_timers) from [<80182a74>] (run_timer_softirq+0x8c/0x164)
[   22.171610] [<80182a74>] (run_timer_softirq) from [<80124a7c>] (__do_softirq+0xac/0x3f0)
[   22.179696] [<80124a7c>] (__do_softirq) from [<80125124>] (irq_exit+0xf0/0x158)
[   22.187003] [<80125124>] (irq_exit) from [<8016ffd4>] (__handle_domain_irq+0x60/0xb8)
[   22.194828] [<8016ffd4>] (__handle_domain_irq) from [<801014c4>] (gic_handle_irq+0x4c/0x9c)
[   22.203175] [<801014c4>] (gic_handle_irq) from [<806cc48c>] (__irq_svc+0x6c/0xa8)
[   22.210648] Exception stack(0x80b01f60 to 0x80b01fa8)
[   22.215694] 1f60: 00000000 bf5c03f0 80b01fb8 8011a060 00000000 00000001 80b03c9c 80b03c2c
[   22.223865] 1f80: 80b1c045 80b1c045 00000001 00000000 80a673f0 80b01fb0 801090c0 801090c4
[   22.232032] 1fa0: 60000013 ffffffff
[   22.235520] [<806cc48c>] (__irq_svc) from [<801090c4>] (arch_cpu_idle+0x38/0x44)
[   22.242914] [<801090c4>] (arch_cpu_idle) from [<80160f00>] (cpu_startup_entry+0xd8/0x148)
[   22.251089] [<80160f00>] (cpu_startup_entry) from [<80a00c44>] (start_kernel+0x360/0x3c8)
[   22.259269] ---[ end trace e04d3944bdde616a ]---



I patched both stmmac_tso_xmit and stmmac_xmit, as instructed.
Here is the diff:

--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2090,8 +2090,9 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
        /* Manage tx mitigation */
        priv->tx_count_frames += nfrags + 1;
        if (likely(priv->tx_coal_frames > priv->tx_count_frames)) {
-               mod_timer(&priv->txtimer,
-                         STMMAC_COAL_TIMER(priv->tx_coal_timer));
+               if (priv->tx_count_frames == nfrags + 1)
+                       mod_timer(&priv->txtimer,
+                                 STMMAC_COAL_TIMER(priv->tx_coal_timer));
        } else {
                priv->tx_count_frames = 0;
                priv->hw->desc->set_tx_ic(desc);
@@ -2292,8 +2293,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
         */
        priv->tx_count_frames += nfrags + 1;
        if (likely(priv->tx_coal_frames > priv->tx_count_frames)) {
-               mod_timer(&priv->txtimer,
-                         STMMAC_COAL_TIMER(priv->tx_coal_timer));
+               if (priv->tx_count_frames == nfrags + 1)
+                       mod_timer(&priv->txtimer,
+                                 STMMAC_COAL_TIMER(priv->tx_coal_timer));
        } else {
                priv->tx_count_frames = 0;
                priv->hw->desc->set_tx_ic(desc);



Without your patch, I get no tx queue timeout, and ping works fine.


>
> You'll need to apply it twice as code is copy&pasted.
>
> Best regards,
> 									Pavel
>
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>
>  	 */
>  	priv->tx_count_frames += nfrags + 1;
>  	if (likely(priv->tx_coal_frames > priv->tx_count_frames)) {
> -		mod_timer(&priv->txtimer,
> -			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
> +		if (priv->tx_count_frames == nfrags + 1)
> +			mod_timer(&priv->txtimer,
> +				  STMMAC_COAL_TIMER(priv->tx_coal_timer));
>  	} else {
>  		priv->tx_count_frames = 0;
>  		priv->hw->desc->set_tx_ic(desc);
>
>
