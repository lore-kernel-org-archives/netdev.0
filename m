From: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Subject: RE: [PATCH] CDC NCM: release interfaces fix in unbind()
Date: Tue, 17 May 2011 02:52:34 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520153E3A93E8EE@EXDCVYMBSTM006.EQ1STM.local>
References: <1305491307-6548-1-git-send-email-alexey.orishko@stericsson.com>
 <20110516.151302.89070822321885499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"gregkh-l3A5Bk7waGM@public.gmane.org" <gregkh-l3A5Bk7waGM@public.gmane.org>,
	"oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org" <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110516.151302.89070822321885499.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> The usb_set_intfdata() calls at cdc_ncm_bind() time are unconditional,
> and are performed regardless of whether ->data_claimed or
> ->control_claimed are set.
> 
> So conditionalizing the setting of them to NULL here doesn't seem
> right at all.
> 
> I'm not applying this patch.

Looks like I have to pay more attention to bind/unbind code as it was
copy-paste to some extent. Looking at cdc-acm and cdc_ether drivers,
there is no need to claim control (master) interface neither release it
in unbind().
Some confusion was added by other driver code that handles crippled
devices, which mix ctrl and data interfaces... Shall not be the case here.
I see, that some clean up can be done and "xxx_claimed" fields in context
structure can be removed, so will post a new version of patch shortly.

Regards,
Alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
