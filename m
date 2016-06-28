From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: Create _rtl_dbg_trace function to reduce
 RT_TRACE code size
Date: Tue, 28 Jun 2016 09:19:51 -0500
Message-ID: <57728787.8060400@lwfinger.net>
References: <90cd7c8f12b51571db565fd496a2fcf610e2e484.1466894688.git.joe@perches.com>
 <5771CA6C.1060403@lwfinger.net> <1467086116.24287.11.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467086116.24287.11.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/27/2016 10:55 PM, Joe Perches wrote:
> On Mon, 2016-06-27 at 19:53 -0500, Larry Finger wrote:
>> On 06/25/2016 05:46 PM, Joe Perches wrote:
>>>
>>> This debugging macro can expand to a lot of code.
>>> Make it a function to reduce code size.
>>>
>>> (x86-64 defconfig w/ all rtlwifi drivers and allyesconfig)
>>> $ size drivers/net/wireless/realtek/rtlwifi/built-in.o*
>>>      text	   data	    bss	    dec	    hex	filename
>>>    900083	 200499	   1907	1102489	 10d299	drivers/net/wireless/realtek/rtlwifi/built-in.o.defconfig.new
>>> 1113597	 200499	   1907	1316003	 1414a3	drivers/net/wireless/realtek/rtlwifi/built-in.o.defconfig.old
>>> 1746879	 453503	   8512	2208894	 21b47e	drivers/net/wireless/realtek/rtlwifi/built-in.o.new
>>> 2051965	 503311	   8512	2563788	 271ecc	drivers/net/wireless/realtek/rtlwifi/built-in.o.old
>>>
>>> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
>> I acked this before; however there is a bug that breaks the build if
>> CONFIG_RTLWIFI_DEBUG is not defined. The rest of the code calls
>> _rtl_dbg_trace(), but that symbol is never defined. The problem can be fixed in
>> debug.c or debug.h.
>
> Confused a bit.  What breaks again?

Nothing breaks and your patch is OK. I had ported it to a GitHub repo of these 
drivers, which had a different debug.h. That led to the missing global when 
CONFIG_RTLWIFI_DEBUG was not defined. That has now been fixed.

Sorry for the confusion.

Larry


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
