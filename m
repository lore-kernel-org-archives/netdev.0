From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 4/8] net/mlx5e: Consider IRQ affinity changes in
 NAPI poll
Date: Mon, 2 Nov 2015 13:25:43 +0200
Message-ID: <CALzJLG_eE-yFwnF=h4Gv7b8UDtG7uYsPKG9p4c4Wc+6RkE8KrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:36430 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbbKBLZn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 06:25:43 -0500
Received: by ykba4 with SMTP id a4so135808313ykb.3
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 03:25:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

We agree with you, we will drop this patch for now and will think of a
cleaner approach to fix this in the future.

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, November 02, 2015 12:34 AM
> To: Or Gerlitz <ogerlitz@mellanox.com>
> Cc: netdev@vger.kernel.org; Saeed Mahameed <saeedm@mellanox.com>; Achiad Shochat <achiad@mellanox.com>
> Subject: Re: [PATCH net-next 4/8] net/mlx5e: Consider IRQ affinity changes in NAPI poll
>
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Sun,  1 Nov 2015 19:35:18 +0200
>
>> @@ -49,6 +50,15 @@ struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
>>       return cqe;
>>  }
>>
>> +static inline bool mlx5e_no_channel_affinity_change(struct
>> +mlx5e_channel *c) {
>> +     int current_cpu = smp_processor_id();
>> +     struct irq_data *d = irq_desc_get_irq_data(c->irq_desc);
>> +     struct cpumask *aff = irq_data_get_affinity_mask(d);
>> +
>> +     return cpumask_test_cpu(current_cpu, aff); }
>
> This is so much pointer dereferencing and then a bitmask test as well.
>
> Are you really sure sure an extremely rare situation warrants this test every single NAPI poll call?
>
> If this is a real problem, then every driver is susceptible to the issue and it therefore warrants a generic solution.  And if we have generic infrastructure for this situation in the code NAPI polling networking code, I guarantee that it will probably be implemented much more cheaply than this.
