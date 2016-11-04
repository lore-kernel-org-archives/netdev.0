From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH 1/2] net: ethernet: nb8800: Do not apply TX delay at MAC
 level
Date: Fri, 4 Nov 2016 16:36:50 +0100
Message-ID: <581CAB12.3030604@laposte.net>
References: <581CA300.1060609@laposte.net>
 <yw1xlgwzjmti.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz300.laposte.net ([178.22.154.200]:57003 "EHLO
        smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S935737AbcKDPgw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 11:36:52 -0400
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout012 (Postfix) with ESMTP id 6EA638CCE1
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 16:36:51 +0100 (CET)
Received: from lpn-prd-vrin002 (lpn-prd-vrin002.prosodie [10.128.63.3])
        by lpn-prd-vrout012 (Postfix) with ESMTP id 68C358CADE
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 16:36:51 +0100 (CET)
Received: from lpn-prd-vrin002 (localhost [127.0.0.1])
        by lpn-prd-vrin002 (Postfix) with ESMTP id 5350C5BF2A5
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 16:36:51 +0100 (CET)
In-Reply-To: <yw1xlgwzjmti.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Måns,

On 11/04/2016 04:18 PM, Måns Rullgård wrote:
> Sebastian Frias <sf84@laposte.net> writes:
> 
>> The delay can be applied at PHY or MAC level, but since
>> PHY drivers will apply the delay at PHY level when using
>> one of the "internal delay" declinations of RGMII mode
>> (like PHY_INTERFACE_MODE_RGMII_TXID), applying it again
>> at MAC level causes issues.
> 
> The Broadcom GENET driver does the same thing.
> 

Well, I don't know who uses that driver, or why they did it that way.

However, with the current code and DT bindings, if one requires
the delay, phy-connection-type="rgmii-txid" must be set.

But when doing so, both the Atheros 8035 and the Aurora NB8800 drivers
will apply the delay.

I think a better way of dealing with this is that both, PHY and MAC
drivers exchange information so that the delay is applied only once.

I can see how to do that in another patch set.

>> Signed-off-by: Sebastian Frias <sf84@laposte.net>
>> ---
>>  drivers/net/ethernet/aurora/nb8800.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
>> index b59aa35..d2855c9 100644
>> --- a/drivers/net/ethernet/aurora/nb8800.c
>> +++ b/drivers/net/ethernet/aurora/nb8800.c
>> @@ -1282,7 +1282,7 @@ static int nb8800_tangox_init(struct net_device *dev)
>>  		break;
>>
>>  	case PHY_INTERFACE_MODE_RGMII_TXID:
>> -		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
>> +		pad_mode = PAD_MODE_RGMII;
>>  		break;
>>
>>  	default:
>> -- 
>> 1.7.11.2
> 
> If this change is correct (and I'm not convinced it is), that case
> should be merged with the one above it and PHY_INTERFACE_MODE_RGMII_RXID
> added as well.
> 

I can do a single patch.

The reason I made two patches was that it was clear what this patch
does, i.e.: do not apply the delay at MAC level, and what the subsequent
patch does, i.e.: handle all RGMII declinations.

Best regards,

Sebastian
