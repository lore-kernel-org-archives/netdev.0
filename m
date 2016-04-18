From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V2 05/11] net/mlx5e: Support RX multi-packet WQE
 (Striding RQ)
Date: Mon, 18 Apr 2016 16:05:42 +0300
Message-ID: <CALzJLG_W9SkgMBQp86P0WDknw4Kc=DCBrvpPemAUbRX=r4r8Yg@mail.gmail.com>
References: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
 <1460928725-18741-6-git-send-email-saeedm@mellanox.com> <1460939371.10638.97.camel@edumazet-glaptop3.roam.corp.google.com>
 <1460983695.10638.113.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:33730 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbcDRNGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 09:06:03 -0400
Received: by mail-yw0-f194.google.com with SMTP id o63so23593711ywe.0
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 06:06:02 -0700 (PDT)
In-Reply-To: <1460983695.10638.113.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2016 at 3:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2016-04-17 at 17:29 -0700, Eric Dumazet wrote:
>
>>
>> If really you need to allocate physically contiguous memory, have you
>> considered converting the order-5 pages into 32 order-0 ones ?
>
> Search for split_page() call sites for examples.
>
>

Thanks Eric, we are already evaluating split_page as we speak.

We did look but could not find any specific alloc_pages API that
allocates many physically contiguous pages with order0 ! so we assume
it is ok to use split_page.

BTW our MPWQE solution doesn't totally rely on huge physically
contiguous memory, as you see in the next two patches we introduce a
fragmented MPWQE approach as a fallback, but we do understand your
concern for the normal flow.
