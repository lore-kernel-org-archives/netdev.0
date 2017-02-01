From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 1/8] net/mlx5: Fixed static checker warnings
Date: Wed, 1 Feb 2017 11:17:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0277BE3@AcuExch.aculab.com>
References: <20170131205843.23235-1-saeedm@mellanox.com>
 <20170131205843.23235-2-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Matan Barak <matanb@mellanox.com>
To: 'Saeed Mahameed' <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.188]:56556 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751807AbdBALRo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 06:17:44 -0500
In-Reply-To: <20170131205843.23235-2-saeedm@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed
> Sent: 31 January 2017 20:59
> From: Or Gerlitz <ogerlitz@mellanox.com>
> 
> For some reason, sparse doesn't like using an expression of type (!x)
> with a bitwise | and &.  In order to mitigate that, we use a local
> variable.
> 
> Since getting a typeof(bitfield) is incorrect, we cast such cases.
...
> +			MLX5_SET(fte_match_set_lyr_2_4, headers_c, first_prio, (u8)mask->vlan_priority);

Ugg nasty casts...
...
>  #define MLX5_SET(typ, p, fld, v) do { \
> +	typeof(v) _v = v; \
..

Why not just 'unsigned int _v = v;

	David
