From: Per Hallsmark <per.hallsmark-8A+B91M1NdOzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH v2] usbnet: enable more aggressive autosuspend
Date: Wed, 12 Nov 2008 10:01:13 +0100
Message-ID: <491A9B59.9080208@t2data.se>
References: <200811071244.17221.oliver@neukum.org>	<49142DC5.8080803@garzik.org>	<200811071324.18697.oliver@neukum.org> <20081107.122236.08276398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081107.122236.08276398.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
> Date: Fri, 7 Nov 2008 13:24:17 +0100
>
>   
>> Am Freitag, 7. November 2008 13:00:05 schrieb Jeff Garzik:
>>     
>>> Oliver Neukum wrote:
>>>       
>>>> Am Freitag, 7. November 2008 09:26:33 schrieb Jeff Garzik:
>>>>         
>>>>> I pondered taking the easy route of fixing this by surrounding the 
>>>>> auto_pm reference with an ifdef, but it seems like usbnet could use a 
>>>>> bit more thought -- it is questionable whether usbnet_suspend/resume 
>>>>> should be built at all, if !CONFIG_PM, even though they are exported.
>>>>>           
>>>> As this is a generic problem, shouldn't we get the compiler to do
>>>> this for us?
>>>>         
>>> Can you be more specific?
>>>       
>> As these methods are static the compiler is able to tell whether they
>> are referenced by anything but the tables. We should be able to set
>> an attribute in the header file that tells the compiler that these methods
>> won't be called and can be omitted in the build. Otherwise we have to ifdef
>> all those methods.
>>     
>
> The problem is that the content of these functions still needs to be
> parsed, so references to ifdef'd out structure members are still going
> to throw errors.
>
> For the time being please add the necessary CONFIG_PM wrappers around
> the suspend and resume methods, as this is what we do tree wide and
> I don't think you want these usbnet changes blocked by some fancy
> compiler facility that hasn't been implemented yet.
>   
Ok, this news I've missed. Should I regenerate the patch or is it 
handled anyway?

Best regards,
Per

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
