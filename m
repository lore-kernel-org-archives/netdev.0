From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: gone with the spring cleanup..
Date: Wed, 13 May 2015 13:55:57 +0300
Message-ID: <55532DBD.1080901@mellanox.com>
References: <5553158D.7000108@mellanox.com>
 <20150513103812.GA2136@nanopsycho.mtl.com>
 <20150513104249.GB2136@nanopsycho.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0067.outbound.protection.outlook.com ([157.56.112.67]:60410
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751459AbbEMK40 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 06:56:26 -0400
In-Reply-To: <20150513104249.GB2136@nanopsycho.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/13/2015 1:42 PM, Jiri Pirko wrote:
>> Looks like the problem might be in named structures which suppose to be
>> >anonymous. Would you try following patch:
> oh, switchdev_obj_vlan and switchdev_obj_ipv4_fib is used in rocker..
> So better:

nope, fails.. if I remove the union (it is struct switchdev_obj has 
strict vlan and ipv4_fib fields) it works. Seems there's some problem 
also with anonymous unions.

>
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index 3b217b4..32ce31d 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -49,24 +49,28 @@ enum switchdev_obj_id {
>   	SWITCHDEV_OBJ_IPV4_FIB,
>   };
>   
> +struct switchdev_obj_vlan {
> +	u16 flags;
> +	u16 vid_start;
> +	u16 vid_end;
> +};
> +
> +struct switchdev_obj_ipv4_fib {
> +	u32 dst;
> +	int dst_len;
> +	struct fib_info *fi;
> +	u8 tos;
> +	u8 type;
> +	u32 nlflags;
> +	u32 tb_id;
> +};
> +
>   struct switchdev_obj {
>   	enum switchdev_obj_id id;
>   	enum switchdev_trans trans;
>   	union {
> -		struct switchdev_obj_vlan {			/* PORT_VLAN */
> -			u16 flags;
> -			u16 vid_start;
> -			u16 vid_end;
> -		} vlan;
> -		struct switchdev_obj_ipv4_fib {		/* IPV4_FIB */
> -			u32 dst;
> -			int dst_len;
> -			struct fib_info *fi;
> -			u8 tos;
> -			u8 type;
> -			u32 nlflags;
> -			u32 tb_id;
> -		} ipv4_fib;
> +		struct switchdev_obj_vlan vlan;
> +		struct switchdev_obj_ipv4_fib ipv4_fib;
>   	};
>   };
>   
