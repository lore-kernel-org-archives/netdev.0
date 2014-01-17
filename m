From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: [PATCH RFC 1/6] net: rfkill: gpio: fix gpio name
 buffer size off by 1
Date: Fri, 17 Jan 2014 17:59:30 +0800
Message-ID: <CAGb2v67L__kusyfSxSc1Rmb6mtJ_VQQF+rCfr1AiUxCemaXMqA@mail.gmail.com>
References: <1389941251-32692-1-git-send-email-wens@csie.org>
 <1389941251-32692-2-git-send-email-wens@csie.org> <063D6719AE5E284EB5DD2968C1650D6D45EA9D@AcuExch.aculab.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org" <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBF764OLAKGQEUTE2AWA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D45EA9D-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Fri, Jan 17, 2014 at 5:46 PM, David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org> wrote:
> From: Chen-Yu Tsai
>> snprintf should be passed the complete size of the buffer, including
>> the space for '\0'. The previous code resulted in the *_reset and
>> *_shutdown strings being truncated.
> ...
>> diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
> ...
>> -     snprintf(rfkill->reset_name, len + 6 , "%s_reset", rfkill->name);
>> -     snprintf(rfkill->shutdown_name, len + 9, "%s_shutdown", rfkill->name);
>> +     snprintf(rfkill->reset_name, len + 7 , "%s_reset", rfkill->name);
>> +     snprintf(rfkill->shutdown_name, len + 10, "%s_shutdown", rfkill->name);
>
> I can't find the context for the above, but they look very dubious.
> I'd expect: snprintf(foo, sizeof foo, ...).
> If you are trying to truncate rfkill->name you need to use %.*s.

The driver allocates these buffers on the fly, a few lines above:

        len = strlen(rfkill->name);
        rfkill->reset_name = devm_kzalloc(&pdev->dev, len + 7, GFP_KERNEL);
        rfkill->shutdown_name = devm_kzalloc(&pdev->dev, len + 10, GFP_KERNEL);

I am not trying to truncate rfkill->name. Rather, the buffer length passed
to snprintf was wrong, so the resulting name was truncated by one character.


Thanks,
ChenYu
