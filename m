From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: Re: linux-next: build failure after merge of the wireless tree
Date: Tue, 28 Jun 2011 15:11:15 -0300
Message-ID: <20110628181115.GB23183@joana>
References: <20110623130317.b3a6085e.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anderson Briglia <anderson.briglia@openbossa.org>,
	Anderson Lizardo <anderson.lizardo@openbossa.org>,
	Bruna Moreira <bruna.moreira@openbossa.org>,
	Vinicius Costa Gomes <vinicius.gomes@openbossa.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110623130317.b3a6085e.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

* Stephen Rothwell <sfr@canb.auug.org.au> [2011-06-23 13:03:17 +1000]:

> Hi John,
> 
> After merging the wireless tree, today's linux-next build (x86_64
> allmodconfig) failed like this:
> 
> net/bluetooth/smp.c: In function 'smp_e':
> net/bluetooth/smp.c:49:21: error: storage size of 'sg' isn't known
> net/bluetooth/smp.c:67:2: error: implicit declaration of function 'sg_init_one'
> net/bluetooth/smp.c:49:21: warning: unused variable 'sg'
> 
> Caused by commit d22ef0bc83c5 ("Bluetooth: Add LE SMP Cryptoolbox
> functions").  Missing include file, presumably.  This batch has been in
> the bluetooth tree since June 14, so it may have been exposed by the
> removal of linux/mm.h from netdevice.h ...
> 
> I have added the following patch as a merge fix up for today.
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 23 Jun 2011 12:58:55 +1000
> Subject: [PATCH] Bluetooth: include scatterlist.h where needed
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  net/bluetooth/smp.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
> index 52e9ec2..a36f870 100644
> --- a/net/bluetooth/smp.c
> +++ b/net/bluetooth/smp.c
> @@ -25,6 +25,7 @@
>  #include <net/bluetooth/l2cap.h>
>  #include <net/bluetooth/smp.h>
>  #include <linux/crypto.h>
> +#include <linux/scatterlist.h>
>  #include <crypto/b128ops.h>

Thanks for pick this patch to wireless tree ;) 

	Gustavo
