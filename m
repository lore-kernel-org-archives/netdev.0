From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] (3/8) ltpc - convert to new initialization
Date: Wed, 03 Sep 2003 20:48:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F568BEA.50904@pobox.com>
References: <20030903164916.2809d4a5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030903164916.2809d4a5.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> -int __init ltpc_probe(struct net_device *dev)
> +struct net_device * __init ltpc_probe(void)
[...]
>  	/* probe for the I/O port address */
> -	if (io != 0x240 && request_region(0x220,8,"ltpc")) {
> -		x = inb_p(0x220+6);
> -		if ( (x!=0xff) && (x>=0xf0) ) {
> -			io = 0x220;
> -			portfound=1;
> -		}
> -		else {
> -			release_region(0x220,8);
> -		}
> -	}
>  	
>  	if (io != 0x220 && request_region(0x240,8,"ltpc")) {
>  		y = inb_p(0x240+6);
>  		if ( (y!=0xff) && (y>=0xf0) ){ 
>  			io = 0x240;
> -			portfound=1;
> -		}
> -		else {
> -			release_region(0x240,8);
> +			goto got_port;
>  		}
> +		release_region(0x240,8);
>  	} 
> -
> -	if(io && !portfound && request_region(io,8,"ltpc")){
> -		portfound = 1;
> -	}
> -	if(!portfound) {
> -		/* give up in despair */
> -		printk(KERN_ERR "LocalTalk card not found; 220 = %02x, 240 = %02x.\n", x,y);
> -		return -1;
> +	if (io != 0x240 && request_region(0x220,8,"ltpc")) {
> +		x = inb_p(0x220+6);
> +		if ( (x!=0xff) && (x>=0xf0) ) {
> +			io = 0x220;
> +			goto got_port;
> +		}
> +		release_region(0x220,8);
>  	}


why did the order of probing change?

It used to be "0x220 -> 0x240", now it's "0x240 -> 0x220"

	Jeff
