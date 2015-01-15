From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH for 3.19 2/3] rtlwifi: Fix handling of new style descriptors
Date: Thu, 15 Jan 2015 11:14:51 -0600
Message-ID: <54B7F58B.7010604@lwfinger.net>
References: <1421257036-5382-1-git-send-email-Larry.Finger@lwfinger.net>	<1421257036-5382-3-git-send-email-Larry.Finger@lwfinger.net>	<877fwoxo7g.fsf@kamboji.qca.qualcomm.com>	<C11178B3EB8EC446A461ADCC3E27182146C9A9F8@rsex2.realsil.com.cn> <87y4p4w8wb.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	=?UTF-8?B?6LCt5p2t5rOi?= <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87y4p4w8wb.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/15/2015 06:00 AM, Kalle Valo wrote:
> Hi Troy,
>
> please avoid top-posting.
>
> =E8=B0=AD=E6=9D=AD=E6=B3=A2 <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org> writes:
>
>> You can find get_available_desc here:
>>
>> diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wirele=
ss/rtlwifi/
>> pci.c
>> index e25faac..a62170e 100644
>> --- a/drivers/net/wireless/rtlwifi/pci.c
>> +++ b/drivers/net/wireless/rtlwifi/pci.c
>> @@ -578,6 +578,13 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw=
 *hw, int
>> prio)
>>                  else
>>                          entry =3D (u8 *)(&ring->desc[ring->idx]);
>>
>> +               if (rtlpriv->cfg->ops->get_available_desc &&
>> +                   rtlpriv->cfg->ops->get_available_desc(hw, prio) =
<=3D 1) {
>> +                       RT_TRACE(rtlpriv, (COMP_INTR | COMP_SEND), D=
BG_DMESG,
>> +                                "no available desc!\n");
>> +                       return;
>> +               }
>
> I don't see rtlpriv->cfg->ops->get_available_desc set here, only bein=
g
> called?

Only one of the drivers (rtl8192ee) needs to implement that routine, wh=
ich is=20
the reason it is checked for non-NULL before it is called. The implemen=
tation is=20
in patch 3 in file rtl8192ee/sw.c where it says:

@@ -241,6 +239,7 @@ static struct rtl_hal_ops rtl8192ee_hal_ops =3D {
  	.set_desc =3D rtl92ee_set_desc,
  	.get_desc =3D rtl92ee_get_desc,
  	.is_tx_desc_closed =3D rtl92ee_is_tx_desc_closed,
+	.get_available_desc =3D rtl92ee_get_available_desc,
  	.tx_polling =3D rtl92ee_tx_polling,
  	.enable_hw_sec =3D rtl92ee_enable_hw_security_config,
  	.init_sw_leds =3D rtl92ee_init_sw_leds,

Larry



--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
