From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Thu, 16 Feb 2017 22:49:49 +0200
Message-ID: <CALzJLG9z_hc4=35e_yToP1j=+QJJ6uaQbvMo9ddmdN1Ar83RbA@mail.gmail.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
 <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
 <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
 <20170214131206.44b644f6@redhat.com> <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
 <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com> <1487087488.8227.53.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S3530_2DYU-3VRmvRYZ3n05OqJZpJ3x02vXQd6Q7FUJQvw@mail.gmail.com>
 <ccc4cb9e-9863-02e1-2789-4869aea3c661@mellanox.com> <CANn89iJip45peBQB9Tn1mWVg+1QYZH+01CqkAUctd3xqwPw8Zg@mail.gmail.com>
 <37bc04eb-71c9-0433-304d-87fcf8b06be3@mellanox.com> <CALx6S36xcEJ9YssZtzQKOy-tufrWWJO533J0nTEzp_ckb5dVjA@mail.gmail.com>
 <CANn89iJayq1r2hLQJSHA1YvZGDOxNuViucf=+syL6BEmFkc2RQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>, Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>, "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>,
	Saeed Mahameed <saeedm@mellanox.com>, Willem de Bruijn <willemb@google.com>,
	Brenden Blanco <bblanco@plumgrid.com>, Alexei Starovoitov <ast@kernel.org>, linux-mm <linux-mm@kvack.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CANn89iJayq1r2hLQJSHA1YvZGDOxNuViucf=+syL6BEmFkc2RQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2017 at 7:11 PM, Eric Dumazet <edumazet@google.com> wrote:
>> You're admitting that Eric's patches improve driver quality,
>> stability, and performance but you're not allowing this in the kernel
>> because "we know what benchmarks our customers are going to run".
>
> Note that I do not particularly care if these patches go in 4.11 or 4.12 really.
>
> I already backported them into our 4.3 based kernel.
>
> I guess that we could at least propose the trivial patch for stable releases,
> since PowerPC arches really need it.
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index cec59bc264c9ac197048fd7c98bcd5cf25de0efd..0f6d2f3b7d54f51de359d4ccde21f4585e6b7852
> 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -102,7 +102,8 @@
>  /* Use the maximum between 16384 and a single page */
>  #define MLX4_EN_ALLOC_SIZE     PAGE_ALIGN(16384)
>
> -#define MLX4_EN_ALLOC_PREFER_ORDER     PAGE_ALLOC_COSTLY_ORDER
> +#define MLX4_EN_ALLOC_PREFER_ORDER min_t(int, get_order(32768),
>          \
> +                                        PAGE_ALLOC_COSTLY_ORDER)
>
>  /* Receive fragment sizes; we use at most 3 fragments (for 9600 byte MTU
>   * and 4K allocations) */

+1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
