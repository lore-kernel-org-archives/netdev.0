From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: RE: [PATCH] gianfar: synchronize DMA API usage by free_skb_rx_queue
 w/ gfar_new_page
Date: Mon, 30 Jan 2017 08:43:32 +0000
Message-ID: <AM5PR0401MB2561120B6F9BE9FF0A46A0E1964B0@AM5PR0401MB2561.eurprd04.prod.outlook.com>
References: <20170129125220.12538-1-asolokha@kb.kras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arseny Solokha <asolokha@kb.kras.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20087.outbound.protection.outlook.com ([40.107.2.87]:60672
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752101AbdA3JAF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Jan 2017 04:00:05 -0500
In-Reply-To: <20170129125220.12538-1-asolokha@kb.kras.ru>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Arseny Solokha [mailto:asolokha@kb.kras.ru]
>Sent: Sunday, January 29, 2017 2:52 PM
>To: Claudiu Manoil <claudiu.manoil@nxp.com>
>Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Arseny Solokha
><asolokha@kb.kras.ru>
>Subject: [PATCH] gianfar: synchronize DMA API usage by free_skb_rx_queue w=
/
>gfar_new_page
>
>From: Arseny Solokha <asolokha@kb.kras.ru>
>
>In spite of switching to paged allocation of Rx buffers, the driver still
>called dma_unmap_single() in the Rx queues tear-down path.
>

Except for the dma-debug part generating the warning, the implementation of=
=20
dma_unmap_single() looks identical to dma_unmap_page(), both wrappers calli=
ng=20
ops->unmap_page() with same params.
But for consistency, dma_unmap_page() seems the better choice indeed.
Thanks.

Acked-by: Claudiu Manoil <claudiu.manoil@nxp.com>
