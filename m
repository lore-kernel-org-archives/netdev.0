From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: use %*ph[C] to dump small buffers
Date: Thu, 27 Sep 2012 10:16:59 -0500
Message-ID: <50646DEB.8020400@lwfinger.net>
References: <1348667852-5957-1-git-send-email-andriy.shevchenko@linux.intel.com> <1348677946.15175.8.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1348677946.15175.8.camel@joe-AO722>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/26/2012 11:45 AM, Joe Perches wrote:
>
> rate_mask uses:
>
> 	u32 ratr_bitmap = (u32) mac->basic_rates;
> ...
> 	u8 rate_mask[5];
> ...
> 	[sets ratr_bitmap as u32]
> ...
> 	*(u32 *)&rate_mask = ((ratr_bitmap & 0x0fffffff) |
> 				      ratr_index << 28);
> ...
> 	rtl92c_fill_h2c_cmd(hw, H2C_RA_MASK, 5, rate_mask);
>
> Looks like a possible endian misuse to me.

Joe,

I had to track the flow through two more routines, but I think your analysis is 
correct. The only BE platform I have does not have any PCIe hardware, thus I can 
only test the USB version. It does not show a major problem, but this one with 
the rate masks would be subtle.

Thanks,

Larry


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
