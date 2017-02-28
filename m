From: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [patch] net/mlx4: && vs & typo
Date: Tue, 28 Feb 2017 22:45:48 +0000
Message-ID: <1D08B61A9CF0974AA09887BE32D889DA0C193A@ULS-OP-MBXIP03.sdcorp.global.sandisk.com>
References: <20170228120215.GA27947@mwanda>
 <1488296129.3056.1.camel@sandisk.com> <1488320630.25838.39.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
        "eugenia-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <eugenia-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        "yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/28/2017 02:23 PM, Joe Perches wrote:=0A=
> On Tue, 2017-02-28 at 15:35 +0000, Bart Van Assche wrote:=0A=
>> On Tue, 2017-02-28 at 15:02 +0300, Dan Carpenter wrote:=0A=
>>> Bitwise & was obviously intended here.=0A=
> []=0A=
>>> diff --git a/include/linux/mlx4/driver.h b/include/linux/mlx4/driver.h=
=0A=
> []=0A=
>>> @@ -109,7 +109,7 @@ static inline void 	(u8 *addr, u64 mac)=0A=
>>>  	int i;=0A=
>>>  =0A=
>>>  	for (i =3D ETH_ALEN; i > 0; i--) {=0A=
>>> -		addr[i - 1] =3D mac && 0xFF;=0A=
>>> +		addr[i - 1] =3D mac & 0xFF;=0A=
>>>  		mac >>=3D 8;=0A=
>>>  	}=0A=
>>>  }=0A=
>>=0A=
>> Is this the only place where such a loop occurs?=0A=
> =0A=
> Seems to be.=0A=
> =0A=
>> Should a put_unaligned_be48()=0A=
>> function be introduced?=0A=
> =0A=
> Why?  This is used exactly once.=0A=
=0A=
Really? Here is an example of another open-coded version of=0A=
put_unaligned_be48() from arch/mips/cavium-octeon/octeon-platform.c:=0A=
=0A=
	new_mac[0] =3D (mac >> 40) & 0xff;=0A=
	new_mac[1] =3D (mac >> 32) & 0xff;=0A=
	new_mac[2] =3D (mac >> 24) & 0xff;=0A=
	new_mac[3] =3D (mac >> 16) & 0xff;=0A=
	new_mac[4] =3D (mac >> 8) & 0xff;=0A=
	new_mac[5] =3D mac & 0xff;=0A=
=0A=
Bart.=0A=
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
