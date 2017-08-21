From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] ethernet: xircom: small clean up in
 setup_xirc2ps_cs()
Date: Mon, 21 Aug 2017 14:52:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD005CC34@AcuExch.aculab.com>
References: <20170821094730.ydm2xwsqbkyadybi@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        Ilya Matveychikov <matvejchikov@gmail.com>,
        Baoquan He <bhe@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Dan Carpenter' <dan.carpenter@oracle.com>,
        Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821094730.ydm2xwsqbkyadybi@mwanda>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter
> Sent: 21 August 2017 10:48
> The get_options() function takes the whole ARRAY_SIZE().  It doesn't
> matter here because we don't use more than 7 elements.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/ethernet/xircom/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
> index f71883264cc0..fd5288ff53b5 100644
> --- a/drivers/net/ethernet/xircom/xirc2ps_cs.c
> +++ b/drivers/net/ethernet/xircom/xirc2ps_cs.c
> @@ -1781,7 +1781,7 @@ static int __init setup_xirc2ps_cs(char *str)
>  	 */
>  	int ints[10] = { -1 };
> 
> -	str = get_options(str, 9, ints);
> +	str = get_options(str, ARRAY_SIZE(ints), ints);
> 
>  #define MAYBE_SET(X,Y) if (ints[0] >= Y && ints[Y] != -1) { X = ints[Y]; }
>  	MAYBE_SET(if_port, 3);

That code looks very dubious to me.
It looks as though it expects all of the ints[] array to be initialised
to -1, not just the first element.

	David
