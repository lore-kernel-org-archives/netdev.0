From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH] gianfar: disable vlan tag insertion by default on 2.6.x
Date: Wed, 15 Oct 2014 18:22:24 +0800
Message-ID: <543E4AE0.2010207@gmail.com>
References: <1413367234-28652-1-git-send-email-Yanjun.Zhu@windriver.com> <20141015100949.GA30089@1wt.eu> <543E4949.1050606@windriver.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060906000309010704070308"
Cc: sandeep.kumar@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Yue.Tao@windriver.com,
	guang.yang@windriver.com, joe@perches.com, festevam@gmail.com,
	richardcochran@gmail.com, clarocq@gmail.com,
	yongjun_wei@trendmicro.com.cn, claudiu.manoil@freescale.com,
	roy.xu@huawei.com, sky.wangfeng@huawei.com,
	zhuyj <zyjzyj2000@gmail.com>
To: yzhu1 <Yanjun.Zhu@windriver.com>, Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <543E4949.1050606@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060906000309010704070308
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 10/15/2014 06:15 PM, yzhu1 wrote:
> On 10/15/2014 06:09 PM, Willy Tarreau wrote:
>> Hi Zhu,
>>
>> On Wed, Oct 15, 2014 at 06:00:33PM +0800, Zhu Yanjun wrote:
>>> In commit f43c75d4b6[gianfar: disable TX vlan based on kernel 2.6.x],
>>> gianfar nic disables TX vlan. But gianfar nic enables vlan tag
>>> insertion by default. This will lead to unusable connections on
>>> some configurations. Since vlan tag insertion is disabled by default
>>> and it is not enabled any longer, it is not necessary to disable it 
>>> again.
>>>
>>> Zhu Yanjun (1):
>>>    gianfar: disable vlan tag insertion by default
>>>
>>>   drivers/net/gianfar.c | 6 ------
>>>   1 file changed, 6 deletions(-)
>>>
>>> -- 
>>> 1.9.1
>> There's no patch in this e-mail. Since you sent another e-mail with 
>> almost
>> the same subject, I'm confused, it's unclear to me whether I only 
>> need to
>> apply the patch in the other one with this commit message or if it's 
>> just
>> that you accidently dropped the patch when sending this e-mail. Could 
>> you
>> please enlighten me ?
>>
>> Thanks,
>> Willy
>>
> Hi, Willy
>
> Sorry. Please apply the patch in the other one with this commit message.
>
> Thanks a lot.
> Zhu Yanjun
>
Hi, Willy

Sorry, it is my fault. Please apply this patch in the attachment.

Thanks a lot.
Zhu Yanjun


--------------060906000309010704070308
Content-Type: text/x-patch;
 name="0001-gianfar-disable-vlan-tag-insertion-by-default.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-gianfar-disable-vlan-tag-insertion-by-default.patch"

>From 48cb11f57e363e8831c4bcaa854d6df23ca300f7 Mon Sep 17 00:00:00 2001
From: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Date: Wed, 15 Oct 2014 16:52:51 +0800
Subject: [PATCH] gianfar: disable vlan tag insertion by default

2.6.x kernels require a similar logic change as commit 51b8cbfc
[gianfar: fix bug caused by e1653c3e] introduces for newer kernels.

Gianfar driver originally enables vlan tag insertion by default.
This will lead to unusable connections on some configurations.

Since gianfar nic vlan tag insertion is disabled by default and 
it is not enabled any longer, it is not necessary to disable it 
again.

Reported-by: Xu Jianrong <roy.xu@huawei.com>
Suggested-by: Wang Feng <sky.wangfeng@huawei.com>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 drivers/net/gianfar.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 8aa2cf6..afdcb41 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1115,7 +1115,6 @@ int startup_gfar(struct net_device *dev)
 	/* keep vlan related bits if it's enabled */
 	if (priv->vlgrp) {
 		rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;
-		tctrl |= TCTRL_VLINS;
 	}
 
 	/* Init rctrl based on our settings */
@@ -1456,11 +1455,6 @@ static void gfar_vlan_rx_register(struct net_device *dev,
 		tempval |= (RCTRL_VLEX | RCTRL_PRSDEP_INIT);
 		gfar_write(&priv->regs->rctrl, tempval);
 	} else {
-		/* Disable VLAN tag insertion */
-		tempval = gfar_read(&priv->regs->tctrl);
-		tempval &= ~TCTRL_VLINS;
-		gfar_write(&priv->regs->tctrl, tempval);
-
 		/* Disable VLAN tag extraction */
 		tempval = gfar_read(&priv->regs->rctrl);
 		tempval &= ~RCTRL_VLEX;
-- 
1.9.1


--------------060906000309010704070308--
