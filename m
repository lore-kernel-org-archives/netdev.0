From: Eric Nelson <eric@nelint.com>
Subject: Re: commit-3ac72b7b63d5 breaks networking on iMX28
Date: Fri, 21 Oct 2016 06:39:35 -0700
Message-ID: <fea86fa6-d74a-43ff-cf60-0d375336a5ba@nelint.com>
References: <bc6aa851-3f52-2274-47dc-4933662648a1@ginzinger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Henri Roosen <henri.roosen@ginzinger.com>, fugang.duan@nxp.com,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33587 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933183AbcJUNji (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 09:39:38 -0400
Received: by mail-pf0-f174.google.com with SMTP id 128so57533779pfz.0
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 06:39:38 -0700 (PDT)
In-Reply-To: <bc6aa851-3f52-2274-47dc-4933662648a1@ginzinger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Henri,

On 10/21/2016 02:19 AM, Henri Roosen wrote:
> Hi,
> 
> Unfortunately commit-3ac72b7b63d5 "net: fec: align IP header in
> hardware" breaks networking on an iMX28 system.
> 
> The commit seems valid for iMX6, where it is tested okay and solves the
> unaligned accesses.
> 
> On iMX28 I still see unaligned accesses and networking is broken. Can
> anyone confirm this?
> 

Reading the i.MX28 reference manual, it appears that this SoC doesn't
have the RACC bit, and I missed removal of the FEC_QUIRK_HAS_RACC flag.

Can you try with this patch?

diff --git a/drivers/net/ethernet/freescale/fec_main.c
b/drivers/net/ethernet/freescale/fec_main.c
index 692ee24..db5eee9 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -96,7 +96,7 @@ static struct platform_device_id fec_devtype[] = {
}, {
.name = "imx28-fec",
.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_SWAP_FRAME |
- FEC_QUIRK_SINGLE_MDIO | FEC_QUIRK_HAS_RACC,
+ FEC_QUIRK_SINGLE_MDIO,
}, {
.name = "imx6q-fec",
.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |

Please advise,


Eric
