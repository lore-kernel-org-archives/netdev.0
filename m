From: Tariq Toukan <ttoukan.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch] net/mlx4: && vs & typo
Date: Wed, 1 Mar 2017 10:34:54 +0200
Message-ID: <bed89872-6741-5411-02dd-5920cd87f430@gmail.com>
References: <20170228120215.GA27947@mwanda>
 <1488296129.3056.1.camel@sandisk.com> <1488320630.25838.39.camel@perches.com>
 <1D08B61A9CF0974AA09887BE32D889DA0C193A@ULS-OP-MBXIP03.sdcorp.global.sandisk.com>
 <alpine.DEB.2.20.1703010746230.2079@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
        "eugenia-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <eugenia-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        "yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>,
        Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.20.1703010746230.2079@hadrien>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 01/03/2017 8:52 AM, Julia Lawall wrote:
> On Tue, 28 Feb 2017, Bart Van Assche wrote:
>
>> On 02/28/2017 02:23 PM, Joe Perches wrote:
>>> On Tue, 2017-02-28 at 15:35 +0000, Bart Van Assche wrote:
>>>> On Tue, 2017-02-28 at 15:02 +0300, Dan Carpenter wrote:
>>>>> Bitwise & was obviously intended here.
>>> []
>>>>> diff --git a/include/linux/mlx4/driver.h b/include/linux/mlx4/driver.h
>>> []
>>>>> @@ -109,7 +109,7 @@ static inline void 	(u8 *addr, u64 mac)
>>>>>  	int i;
>>>>>
>>>>>  	for (i = ETH_ALEN; i > 0; i--) {
>>>>> -		addr[i - 1] = mac && 0xFF;
>>>>> +		addr[i - 1] = mac & 0xFF;
>>>>>  		mac >>= 8;
>>>>>  	}
>>>>>  }
>>>>
>>>> Is this the only place where such a loop occurs?
>>>
>>> Seems to be.
>>>
>>>> Should a put_unaligned_be48()
>>>> function be introduced?
>>>
>>> Why?  This is used exactly once.
>>
>> Really? Here is an example of another open-coded version of
>> put_unaligned_be48() from arch/mips/cavium-octeon/octeon-platform.c:
>>
>> 	new_mac[0] = (mac >> 40) & 0xff;
>> 	new_mac[1] = (mac >> 32) & 0xff;
>> 	new_mac[2] = (mac >> 24) & 0xff;
>> 	new_mac[3] = (mac >> 16) & 0xff;
>> 	new_mac[4] = (mac >> 8) & 0xff;
>> 	new_mac[5] = mac & 0xff;
>
> drivers/media/radio/radio-shark2.c:
>         for (i = 0; i < 6; i++)
>                shark->transfer_buffer[i + 1] = (reg >> (40 - i * 8)) & 0xff;
>
> drivers/rtc/rtc-ab3100.c
>        buf[0] = (hw_counter) & 0xFF;
>        buf[1] = (hw_counter >> 8) & 0xFF;
>        buf[2] = (hw_counter >> 16) & 0xFF;
>        buf[3] = (hw_counter >> 24) & 0xFF;
>        buf[4] = (hw_counter >> 32) & 0xFF;
>        buf[5] = (hw_counter >> 40) & 0xFF;
>
> drivers/net/ethernet/sun/ldmvsw.c
>         for (i = 0; i < ETH_ALEN; i++)
>                port->raddr[i] = (*rmac >> (5 - i) * 8) & 0xff;
>
> drivers/net/ethernet/sun/sunvnet.c
>         for (i = 0; i < ETH_ALEN; i++)
>                dev->dev_addr[i] = (*local_mac >> (5 - i) * 8) & 0xff;
>
>         for (i = 0; i < ETH_ALEN; i++)
>                port->raddr[i] = (*rmac >> (5 - i) * 8) & 0xff;
>
> julia
>

With these code replication examples, I agree that a function should be 
introduced.

>>
>> Bart.
>> --
>> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
