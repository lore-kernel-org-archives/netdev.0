From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 02/10] net/mlx4_core: Mask out host side
 virtualization features for guests
Date: Tue, 9 Dec 2014 22:25:38 +0200
Message-ID: <CAJ3xEMg-0eYkcbYbsdPbeA1z5xohvVWNCbrfVPBDJq3C9DdwVA@mail.gmail.com>
References: <1417698835-11050-1-git-send-email-ogerlitz@mellanox.com>
	<1417698835-11050-3-git-send-email-ogerlitz@mellanox.com>
	<20141209.144046.110046237866554513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:62397 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbaLIUZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 15:25:38 -0500
Received: by mail-ob0-f180.google.com with SMTP id wp4so1074947obc.25
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 12:25:38 -0800 (PST)
In-Reply-To: <20141209.144046.110046237866554513.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 9, 2014 at 9:40 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Thu,  4 Dec 2014 15:13:47 +0200
>
>> @@ -1053,6 +1053,11 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
>>       field &= ~0x80;
>>       MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_FLOW_STEERING_IPOIB_OFFSET);
>>
>> +     /* turn off host side virt features (VST, FSM, etc) for guests */
>> +     MLX4_GET(field32, outbox->buf, QUERY_DEV_CAP_EXT_2_FLAGS_OFFSET);
>> +     field32 &= ~((1 << 26) | (1 << 21) | (1 << 20));
>> +     MLX4_PUT(outbox->buf, field32, QUERY_DEV_CAP_EXT_2_FLAGS_OFFSET);
>> +
>
> Please use mnenomics instead of magic constants for this, thanks.

OK, will do, if possible, I will be happy to send this as small fix in
a later (tomorrow!!) patch, thanks, Or.
