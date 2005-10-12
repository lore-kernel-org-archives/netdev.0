From: Daniele Venzano <venza@brownhat.org>
Subject: Re: [PATCH] Add Wake on LAN support to sis900
Date: Wed, 12 Oct 2005 19:32:07 +0200
Message-ID: <0A6A690F-B394-4C70-B2B8-74D2271D14AB@brownhat.org>
References: <20051006111326.GA3242@renditai.milesteg.arr> <20051011205304.34bc07ad.akpm@osdl.org>
Mime-Version: 1.0 (Apple Message framework v734)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20051011205304.34bc07ad.akpm@osdl.org>
To: Andrew Morton <akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Il giorno 12/ott/05, alle ore 05:53, Andrew Morton ha scritto:
>> --- ../../trunk/sis900.h    2005-07-17 10:43:23.000000000 +0200
>> +++ sis900.h    2005-10-06 12:49:37.000000000 +0200
>>
>
> Please prepare patches in `patch -p1' form.  See
> http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt.
Yes, I did send a corrected patch some days later, when I found out.  
This was the only correction I made there, so you can just trash it.

>> +    /* Detect Wake on Lan support */
>> +    ret = inl(CFGPMC & PMESP);
>> +    if (netif_msg_probe(sis_priv) && (ret & PME_D3C) == 0)
>> +        printk(KERN_INFO "%s: Wake on LAN only available from  
>> suspend to RAM.", net_dev->name);
>> +
>>
>
> How come?  Why doesn't it work after an ordinary `halt -p'?
That register should report, according to the specs, the status of  
the additional power supply needed to keep awake the chip when the  
computer is shut down. Usually there is an additional cable to be  
installed between the NIC and the motherboard, but on laptops or  
embedded chips it's difficult to know.

>> @@ -2015,6 +2082,8 @@
>>      .get_settings    = sis900_get_settings,
>>      .set_settings    = sis900_set_settings,
>>      .nway_reset    = sis900_nway_reset,
>> +    .get_wol    = sis900_get_wol,
>> +    .set_wol    = sis900_set_wol
>>  };
>>
>
> We normally add a comma to the final field so that subsequent  
> patches look
> cleaner.
Will do.

Thanks for the comments.
--
Daniele Venzano
http://www.brownhat.org
