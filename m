From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 1/2] sh_eth: Fix promiscuous mode on chips without
 TSU
Date: Fri, 16 Jan 2015 22:36:42 +0300
Message-ID: <54B9684A.8060302@cogentembedded.com>
References: <1421430592.1222.190.camel@xylophone.i.decadent.org.uk> <1421430672.1222.191.camel@xylophone.i.decadent.org.uk> <54B9663D.2040008@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>,
	ct178-internal@lists.codethink.co.uk,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:42732 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755131AbbAPTgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 14:36:47 -0500
Received: by mail-lb0-f178.google.com with SMTP id u14so20097345lbd.9
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 11:36:45 -0800 (PST)
In-Reply-To: <54B9663D.2040008@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/2015 10:27 PM, Sergei Shtylyov wrote:

>> Currently net_device_ops::set_rx_mode is only implemented for
>> chips with a TSU (multiple address table).  However we do need
>> to turn the PRM (promiscuous) flag on and off for other chips.

[...]

>> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>

[...]

>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
>> b/drivers/net/ethernet/renesas/sh_eth.c
>> index 167737f..0c4d5b5 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
>> @@ -2440,7 +2440,7 @@ static void sh_eth_tsu_purge_mcast(struct net_device
>> *ndev)
>>       void *reg_offset = sh_eth_tsu_get_offset(mdp, TSU_ADRH0);
>>       int i;
>>
>> -    if (unlikely(!mdp->cd->tsu))
>> +    if (!mdp->cd->tsu)

>     But we don't call this function on non-TSU SoCs, do we?

    Sorry, we do.

> [...]

WBR, Sergei
