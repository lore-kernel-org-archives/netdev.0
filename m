From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH v2 net-next 1/2] net: dsa: lan9303: Add port_fast_age and
 port_fdb_dump methods
Date: Thu, 19 Oct 2017 16:51:11 +0200
Message-ID: <35ba7e49-ac43-4d05-7258-3ac039d33e59@egil-hjelmeland.no>
References: <20171019121015.7395-1-privat@egil-hjelmeland.no>
 <20171019121015.7395-2-privat@egil-hjelmeland.no>
 <87mv4nw869.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20171019141505.GA14840@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019141505.GA14840@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19. okt. 2017 16:15, Andrew Lunn wrote:
>>> +/* Clear learned (non-static) entry on given port */
>>> +static void alr_loop_cb_del_port_learned(struct lan9303 *chip, u32 dat0,
>>> +					 u32 dat1, int portmap, void *ctx)
>>> +{
>>> +	int *port = ctx;
>>
>> You can get the value directly to make the line below more readable:
>>
>>      int port = *(int *)ctx;
> 
> You have to be a bit careful with this. You often see people
> submitting patches taking away casts for void * pointers.
> If they do that here, it should at least not compile...
> 
> So maybe do it in two steps?
> 
>     int * pport = ctx;
>     int port = *pport;
> 
> ???
> 	Andrew
> 

Without cast

    int port = *ctx;

... I can not compile. Neither arm-v5te-linux-gnueabi-gcc 4.7.2 or 
native 64bit gcc 6.3.0.

So I feel it is safe to do as Vivien suggest.

Egil
