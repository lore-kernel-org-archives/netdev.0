From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH v4 net-next 8/9] net: add a hardware buffer management
 helper API
Date: Sun, 6 Mar 2016 20:21:51 +0100
Message-ID: <CAPv3WKeTGy+HfG=vyY04xi4Spy6eUTF_LX_X=V0=ZAGhxURdJg@mail.gmail.com>
References: <1457217507-10778-1-git-send-email-gregory.clement@free-electrons.com>
	<1457217507-10778-9-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Timor Kardashov <timork@marvell.com>,
	Sebastian Careba <nitroshift@yahoo.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:33277 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbcCFTVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 14:21:52 -0500
Received: by mail-ob0-f180.google.com with SMTP id fz5so89560551obc.0
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 11:21:52 -0800 (PST)
In-Reply-To: <1457217507-10778-9-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gregory,


> +int hwbm_pool_add(struct hwbm_pool *bm_pool, unsigned int buf_num, gfp_t gfp)
> +{
> +       int err, i;
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&bm_pool->lock, flags);
> +       if (bm_pool->buf_num == bm_pool->size) {

'size' field is used as a 'frag_size' but here it means pool capacity.
I think it's better to keep 'size' for pool capacity and add
'buf_size' field to struct hwbm_pool.

> +               pr_warn("pool already filled\n");
> +               return bm_pool->buf_num;
> +       }
> +
> +       if (buf_num + bm_pool->buf_num > bm_pool->size) {
> +               pr_warn("cannot allocate %d buffers for pool\n",
> +                       buf_num);
> +               return 0;
> +       }
> +
> +       if ((buf_num + bm_pool->buf_num) < bm_pool->buf_num) {

What is a point of this condition? How possibly after checking if
capacity of pool is not exceeded, this one would ever be true?

> +               pr_warn("Adding %d buffers to the %d current buffers will overflow\n",
> +                       buf_num,  bm_pool->buf_num);
> +               return 0;
> +       }
> +

Best regards,
Marcin
