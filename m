From: Murilo Opsfelder Araujo <mopsfelder-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V3.18] rtlwifi: Add check for get_btc_status callback
Date: Fri, 24 Oct 2014 17:09:34 -0200
Message-ID: <544AA3EE.7080806@gmail.com>
References: <1414081629-23002-1-git-send-email-Larry.Finger@lwfinger.net>	 <1414087731.5231.19.camel@marge.simpson.net>	 <5449478B.4070908@lwfinger.net> <1414116580.23080.10.camel@marge.simpson.net> <544A80B5.1090604@lwfinger.net> <544A96C0.8030107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Thadeu Cascardo <cascardo-s4Flwc3xefXVny7hquFfmQ@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Mike Galbraith <umgwanakikbuti-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <544A96C0.8030107-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/24/2014 04:13 PM, Murilo Opsfelder Araujo wrote:
> On 10/24/2014 02:39 PM, Larry Finger wrote:
> [...]
>>
>> Please try the attached patch. It replaces the second one I sent you. I
>> will probably redo it before submitting the final copy, but this should
>> work.
>>
>> Larry
>>
> Hi, Larry.
>
> I've tried your patch on top of next-20141023 and it is still crashing
> on my laptop:
>
> http://opsfelder.com/~murilo/lkml/next-20141023_plus_larry_patch_v2.jpg
>
It seems a get_btc_status() check was still missing:

diff --git a/drivers/net/wireless/rtlwifi/pci.c 
b/drivers/net/wireless/rtlwifi/pci.c
index a5a350a..ed3364d 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1796,7 +1796,8 @@ static int rtl_pci_start(struct ieee80211_hw *hw)
         rtl_pci_reset_trx_ring(hw);

         rtlpci->driver_is_goingto_unload = false;
-       if (rtlpriv->cfg->ops->get_btc_status()) {
+       if (rtlpriv->cfg->ops->get_btc_status &&
+           rtlpriv->cfg->ops->get_btc_status()) {
                 rtlpriv->btcoexist.btc_ops->btc_init_variables(rtlpriv);
                 rtlpriv->btcoexist.btc_ops->btc_init_hal_vars(rtlpriv);
         }

With this minor change and Larry's latest fix_misc_desc patch, 
next-20141023 booted normally and kernel panic disappeared.

Now, there is no wifi network available or found by wlan0.

-- 
Murilo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
