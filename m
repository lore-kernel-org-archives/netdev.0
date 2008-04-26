From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH][CAN]: Fix copy_from_user() results interpretation.
Date: Sat, 26 Apr 2008 10:26:34 +0200
Message-ID: <4812E73A.6060104@hartkopp.net>
References: <4811D1A6.909@openvz.org> <4811E915.80303@volkswagen.de>	<4812C973.5000504@grandegger.com> <20080426064007.GA20558@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	"Thuermann, Urs, Dr. \(K-EFFI/I\)" <urs.thuermann@volkswagen.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	socketcan-core@lists.berlios.de,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Pavel Emelyanov <xemul@openvz.org>
To: Sam Ravnborg <sam@ravnborg.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:28870 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209AbYDZI0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 04:26:54 -0400
In-Reply-To: <20080426064007.GA20558@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sam Ravnborg wrote:
> On Sat, Apr 26, 2008 at 08:19:31AM +0200, Wolfgang Grandegger wrote:
>   
>> What about removing the assignment "err =" in that case.
>>     
> Preferred.
>
> See sample patch below (made on top of -linus
> so it does likely not apply but made it only to
> see the difference anyway).
>   


I can definitely follow Daves remarks regarding the ability to review 
local bugfixes. In this case two commits should be used.

Btw. the cleanup an removal of the err variable usage in the pointed 
cases is a good suggestion. So even when the two latest changes in Sam's 
patch are not that obvious to be able to be reviewed locally i would 
like to ack this patch.

It should apply fine on Linus' tree and the current net-2.6.

Thanks to all of you & have a nice weekend.

Oliver

Acked-by: Oliver Hartkopp <oliver@hartkopp.net>

> diffstat:
>  net/can/raw.c          |   21 ++++++++++-----------
>  2 files changed, 11 insertions(+), 12 deletions(-)
>
> diff --git a/net/can/raw.c b/net/can/raw.c
> index 201cbfc..69877b8 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
> @@ -435,15 +435,13 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
>  			if (!filter)
>  				return -ENOMEM;
>  
> -			err = copy_from_user(filter, optval, optlen);
> -			if (err) {
> +			if (copy_from_user(filter, optval, optlen)) {
>  				kfree(filter);
> -				return err;
> +				return -EFAULT;
>  			}
>  		} else if (count == 1) {
> -			err = copy_from_user(&sfilter, optval, optlen);
> -			if (err)
> -				return err;
> +			if (copy_from_user(&sfilter, optval, optlen))
> +				return -EFAULT;
>  		}
>  
>  		lock_sock(sk);
> @@ -493,9 +491,8 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
>  		if (optlen != sizeof(err_mask))
>  			return -EINVAL;
>  
> -		err = copy_from_user(&err_mask, optval, optlen);
> -		if (err)
> -			return err;
> +		if (copy_from_user(&err_mask, optval, optlen))
> +			return -EFAULT;
>  
>  		err_mask &= CAN_ERR_MASK;
>  
> @@ -531,7 +528,8 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
>  		if (optlen != sizeof(ro->loopback))
>  			return -EINVAL;
>  
> -		err = copy_from_user(&ro->loopback, optval, optlen);
> +		if (copy_from_user(&ro->loopback, optval, optlen))
> +			return -EFAULT;
>  
>  		break;
>  
> @@ -539,7 +537,8 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
>  		if (optlen != sizeof(ro->recv_own_msgs))
>  			return -EINVAL;
>  
> -		err = copy_from_user(&ro->recv_own_msgs, optval, optlen);
> +		if (copy_from_user(&ro->recv_own_msgs, optval, optlen))
> +			return -EFAULT;
>  
>  		break;
>  
> _______________________________________________
> Socketcan-core mailing list
> Socketcan-core@lists.berlios.de
> https://lists.berlios.de/mailman/listinfo/socketcan-core
>   

