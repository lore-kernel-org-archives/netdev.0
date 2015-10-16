From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: hix5hd2_gmac: avoid integer overload warning
Date: Fri, 16 Oct 2015 21:50:21 +0300
Message-ID: <562146ED.1030308@cogentembedded.com>
References: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
 <4752736.dePgPCNd9q@wuerfel>
 <063D6719AE5E284EB5DD2968C1650D6D1CBB97A6@AcuExch.aculab.com>
 <9667302.4m5v3ViVSt@wuerfel> <1445018654.22921.41.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
	huangdaode <huangdaode@hisilicon.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"liguozhu@hisilicon.com" <liguozhu@hisilicon.com>,
	"Yisen.Zhuang@huawei.com" <Yisen.Zhuang@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxarm@huawei.com" <linuxarm@huawei.com>,
	"salil.mehta@huawei.com" <salil.mehta@huawei.com>,
	"kenneth-lee-2012@foxmail.com" <kenneth-lee-2012@foxmail.com>,
	"xuwei5@hisilicon.com" <xuwei5@hisilicon.com>,
	"lisheng011@huawei.com" <lisheng011@huawei.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"lipeng321@huawei.com" <lipeng321@huawei.com>
To: Joe Perches <joe@perches.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:33813 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932554AbbJPSuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 14:50:25 -0400
Received: by lbbwb3 with SMTP id wb3so45224103lbb.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 11:50:24 -0700 (PDT)
In-Reply-To: <1445018654.22921.41.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2015 09:04 PM, Joe Perches wrote:

>>>> BITS_RX_EN is an 'unsigned long' constant, so the ones complement of that
>>>> has bits set that do not fit into a 32-bit variable on 64-bit architectures,
>>>> which causes a harmless gcc warning:
>>> ...
>>>>   static void hix5hd2_port_disable(struct hix5hd2_priv *priv)
>>>>   {
>>>> -     writel_relaxed(~(BITS_RX_EN | BITS_TX_EN), priv->base + PORT_EN);
>>>> +     writel_relaxed(~(u32)(BITS_RX_EN | BITS_TX_EN), priv->base + PORT_EN);
>>>>        writel_relaxed(0, priv->base + DESC_WR_RD_ENA);
>>>
>>> ISTM that just means that the constants shouldn't be 'long'.
>>
>> Right, but that would probably mean changing the BIT() macro or not using it
>> here. In the past I've argued against using that macro, but I've given
>> up that fight.
>
> Fight on... (Somebody must have gone to USC here)
>
> There might be value in a BIT_U32 macro.
> Maybe BIT_U64 too.

    There's BIT_ULL() already.

MBR, Sergei
