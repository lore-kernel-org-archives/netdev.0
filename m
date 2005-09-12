From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: Allow for > 8 byte hardware
	addresses.
Date: Mon, 12 Sep 2005 14:13:51 -0700 (PDT)
Message-ID: <20050912.141351.50320521.davem@davemloft.net>
References: <1123786117.4403.5835.camel@hal.voltaire.com>
	<20050811.124916.77057824.davem@davemloft.net>
	<m164t8ltrs.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: ebiederm@xmission.com
In-Reply-To: <m164t8ltrs.fsf_-_@ebiederm.dsl.xmission.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 10 Sep 2005 11:25:27 -0600

> @@ -1315,11 +1340,16 @@ packet_setsockopt(struct socket *sock, i
>  	case PACKET_ADD_MEMBERSHIP:	
>  	case PACKET_DROP_MEMBERSHIP:
>  	{
> -		struct packet_mreq mreq;
> -		if (optlen<sizeof(mreq))
> +		struct packet_mreq_max mreq;
> +		int len = optlen;
> +		if (len < sizeof(struct packet_mreq))
>  			return -EINVAL;
> -		if (copy_from_user(&mreq,optval,sizeof(mreq)))
> +		if (len > sizeof(mreq))
> +			len = sizeof(mreq);
> +		if (copy_from_user(&mreq,optval,len))
>  			return -EFAULT;

I would suggest memset()'ing out any packet_mreq_max structure,
before copying a smaller amount of data into it, just to be
safe.  Please check this out in all such possible uses in
the patch.

Thanks.
