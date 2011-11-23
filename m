From: walter harms <wharms@bfs.de>
Subject: Re: [patch] netrom: check that user string is terminated
Date: Wed, 23 Nov 2011 09:22:16 +0100
Message-ID: <4ECCAD38.9090309@bfs.de>
References: <20111123065240.GD6871@elgon.mountain>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20111123065240.GD6871@elgon.mountain>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 23.11.2011 07:52, schrieb Dan Carpenter:
> We do an strcpy() of mnemonic in nr_add_node().
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
> index 915a87b..e126c48 100644
> --- a/net/netrom/nr_route.c
> +++ b/net/netrom/nr_route.c
> @@ -670,6 +670,8 @@ int nr_rt_ioctl(unsigned int cmd, void __user *arg)
>  	case SIOCADDRT:
>  		if (copy_from_user(&nr_route, arg, sizeof(struct nr_route_struct)))
>  			return -EFAULT;
> +		if (strlen(nr_route.mnemonic) >= sizeof(nr_route.mnemonic))
> +			return -EINVAL;


I am not sure that it does what you intends.
mnemonic is an array and a  malicious use may fill it upto the last char
causing strlen go beyond. perhaps this may help:
	nr_route.mnemonic[sizeof(nr_route.mnemonic)-1]=0;
this of cause makes the if() redundant.



>  		if ((dev = nr_ax25_dev_get(nr_route.device)) == NULL)
>  			return -EINVAL;
while you are here:

	dev = nr_ax25_dev_get(nr_route.device);
	if ( dev == NULL )
		return -EINVAL;

>  		if (nr_route.ndigis < 0 || nr_route.ndigis > AX25_MAX_DIGIS) {

if guess "nr_route.ndigis >= AX25_MAX_DIGIS" is intended ?

hope that helps,
 wh

> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
