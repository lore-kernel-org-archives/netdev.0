From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: [PATCH] kill rtnl_exlock stubs
Date: 29 Jul 2004 09:16:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1091106988.1045.654.camel@jzny.localdomain>
References: <20040727095057.78c7419c@dell_ss3.pdx.osdl.net>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Alexey <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040727095057.78c7419c@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-07-27 at 12:50, Stephen Hemminger wrote:

> @@ -404,13 +402,8 @@
>  		return -1;
>  	}
>  
> -	if (kind != 2) {
> -		if (rtnl_exlock_nowait()) {
> -			*errp = 0;
> -			return -1;
> -		}
> +	if (kind != 2) 
>  		exclusive = 1;
> -	}
>  
>  	memset(&rta, 0, sizeof(rta));
>  
> @@ -439,14 +432,10 @@
>  		goto err_inval;
>  	err = link->doit(skb, nlh, (void *)&rta);
>  
> -	if (exclusive)
> -		rtnl_exunlock();
>  	*errp = err;
>  	return err;
>  
>  err_inval:
> -	if (exclusive)
> -		rtnl_exunlock();
>  	*errp = -EINVAL;
>  	return -1;
>  }

This piece is the only one i would worry about.
I dont remember the historical reasoning for rtnl_ex* I know its not
useful as is right now. OTOH, if it was useful then the above code would
have meant something. Dave/Alexey?

cheers,
jamal
