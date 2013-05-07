From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH 3/8] net: sh-eth: Remove duplicate sh_eth_set_duplex()
Date: Tue, 07 May 2013 14:00:49 +0900
Message-ID: <51888A81.2000602@renesas.com>
References: <1366268510-8121-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <1366268510-8121-3-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <516FFF53.6010701@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor2.renesas.com ([210.160.252.172]:52817 "EHLO
	relmlor2.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175Ab3EGFAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:00:50 -0400
Received: from relmlir3.idc.renesas.com ([10.200.68.153])
 by relmlor2.idc.renesas.com ( SJSMS)
 with ESMTP id <0MME00BHQWLDG7B0@relmlor2.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 14:00:49 +0900 (JST)
Received: from relmlac4.idc.renesas.com ([10.200.69.24])
 by relmlir3.idc.renesas.com ( SJSMS)
 with ESMTP id <0MME00KA9WLD3Z50@relmlir3.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 14:00:49 +0900 (JST)
In-reply-to: <516FFF53.6010701@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(2013/04/18 23:12), Sergei Shtylyov wrote:
> Hello.
>
> On 18-04-2013 11:01, Nobuhiro Iwamatsu wrote:
>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>
> Step in the right direction.
>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
>> index 313d6ef..5c4e82c 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>> @@ -341,9 +341,11 @@ static void sh_eth_select_mii(struct net_device *ndev)
>> }
>> #endif
>>
>> -/* There is CPU dependent code */
>> -#if defined(CONFIG_ARCH_R8A7779)
>> -#define SH_ETH_RESET_DEFAULT 1
>> +#if defined(CONFIG_CPU_SUBTYPE_SH7619) || \
>> + defined(CONFIG_CPU_SUBTYPE_SH7710) || \
>> + defined(CONFIG_CPU_SUBTYPE_SH7712)
>> +# define sh_eth_set_duplex NULL
>
> I don't think this is neeeded at all.
>
>> +#else
>> static void sh_eth_set_duplex(struct net_device *ndev)
>> {
>> struct sh_eth_private *mdp = netdev_priv(ndev);
>> @@ -353,7 +355,11 @@ static void sh_eth_set_duplex(struct net_device *ndev)
>> else /* Half */
>> sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
>> }
>> +#endif
>>
>> +/* There is CPU dependent code */
>> +#if defined(CONFIG_ARCH_R8A7779)
>> +#define SH_ETH_RESET_DEFAULT 1
>> static void sh_eth_set_rate(struct net_device *ndev)
>> {
>> struct sh_eth_private *mdp = netdev_priv(ndev);
> [...]
>> @@ -834,6 +791,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
>> #elif defined(CONFIG_CPU_SUBTYPE_SH7619)
>> #define SH_ETH_RESET_DEFAULT 1
>> static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
>> + .set_duplex = sh_eth_set_duplex,
>
> Please, align = like in other initializers.
> Wait, is this change legitimate at all? You mean NULL will be set here?
> But why bother doing this, when 0s will be set to all fields without
> explicit initializer?

Yah, this is mybad.

>
>> .eesipr_value = DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
>>
>> .apr = 1,
>> @@ -845,6 +803,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
>> #define SH_ETH_RESET_DEFAULT 1
>> #define SH_ETH_HAS_TSU 1
>> static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
>> + .set_duplex = sh_eth_set_duplex,
>
> Same coments here.
>
I see.
I will remove sh_eth_set_duplex from SH7619, SH7710 and SH7712.

Thanks,
   Nobuhiro
