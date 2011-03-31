From: wu zhangjin <wuzhangjin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH] rtl8187: Fix led support for rfkill
Date: Fri, 1 Apr 2011 00:22:51 +0800
Message-ID: <AANLkTinwG5BR5=S14XYcwZ39c3k0xc9+2VsQFS+JHB0f@mail.gmail.com>
References: <1301174394-12642-1-git-send-email-wuzhangjin@gmail.com>
	<4D8E5BA3.1090909@users.sourceforge.net>
	<AANLkTind3Va9J_tvZBDAPfbuyQtgxoAE+ZzG6VpU1b1q@mail.gmail.com>
	<4D8E8B1E.3030709@users.sourceforge.net>
	<4D8FBE88.3050907@lwfinger.net>
	<20110328154046.GB2333@herton-IdeaPad-Y430>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Hin-Tak Leung <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Herton Ronaldo Krzesinski <herton-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Roman Mamedov <rm-pzoh41kZ4TQvJsYlp49lxw@public.gmane.org>
To: Herton Ronaldo Krzesinski <herton.krzesinski-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110328154046.GB2333@herton-IdeaPad-Y430>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 28, 2011 at 11:40 PM, Herton Ronaldo Krzesinski
<herton.krzesinski-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
[...]
>>
>> My rtl8187 devices are both external USB sticks, thus they have no
>> interaction with a radio-kill switch. I will test your patch to make
>> sure it does no harm to my system.
>>
>> I think the commit message should be revised. A simple statement
>> like "the LED does not turn off when the rfkill switch is off"
>> should be sufficient.
>
> The patch should work, but I wonder if we should be fiddling with priv->vif
> for this, perhaps we should not assume vif to be valid after
> rtl8187_remove_interface (I don't see problems with current
> rtl8187/mac80211 code on a quick look, but...)
>

Yes, but seems only two places have touched the vif pointer.

$ grep "vif =" -ur drivers/net/wireless/rtl818x/rtl8187/
drivers/net/wireless/rtl818x/rtl8187/dev.c:	priv->vif = NULL;
drivers/net/wireless/rtl818x/rtl8187/dev.c:	priv->vif = vif;

> I cleaner solution may be to use a priv->mode like p54.

Yep, then, we may need to add a 'mode' member to rtl8187_priv and
update it properly like p54.

So, What do you prefer? I will prepare a new patch asap.

Best Regards,
Wu Zhangjin

>
>>
>> Larry
>>
>
> --
> []'s
> Herton
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
