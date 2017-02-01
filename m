From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 1/8] net/mlx5: Fixed static checker warnings
Date: Wed, 1 Feb 2017 18:39:48 +0200
Message-ID: <CAJ3xEMgKUTGCr+AXuHgEm_r=KpMf0mEyp8sxC4o1PF3p9KjMRA@mail.gmail.com>
References: <20170131205843.23235-1-saeedm@mellanox.com> <20170131205843.23235-2-saeedm@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0277BE3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Matan Barak <matanb@mellanox.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:33963 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751111AbdBAQjt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 11:39:49 -0500
Received: by mail-ot0-f196.google.com with SMTP id 73so45922363otj.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 08:39:48 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0277BE3@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 1, 2017 at 1:17 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Saeed Mahameed
>> Sent: 31 January 2017 20:59
>> From: Or Gerlitz <ogerlitz@mellanox.com>
>>
>> For some reason, sparse doesn't like using an expression of type (!x)
>> with a bitwise | and &.  In order to mitigate that, we use a local
>> variable.
>>
>> Since getting a typeof(bitfield) is incorrect, we cast such cases.
> ...
>> +                     MLX5_SET(fte_match_set_lyr_2_4, headers_c, first_prio, (u8)mask->vlan_priority);
>
> Ugg nasty casts...
> ...
>>  #define MLX5_SET(typ, p, fld, v) do { \
>> +     typeof(v) _v = v; \
> ..
>
> Why not just 'unsigned int _v = v;

Yeah, basically we could have allocate (use) the max size and assign.
We preferred to allocate the specific instance size and use this, as using t
he required size is cleaner.

Or.
