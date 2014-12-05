From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: Is this 32-bit NCM?y
Date: Fri, 05 Dec 2014 10:42:46 +0100
Message-ID: <8761dqjuuh.fsf@nemi.mork.no>
References: <AMSPR06MB6011E001029C251790CB923EE780@AMSPR06MB601.eurprd06.prod.outlook.com>
	<877fy7myfb.fsf@nemi.mork.no>
	<alpine.LNX.2.03.1412041326160.9926@gmail.com>
	<54811670.5030703@audiocodes.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Midge Shaojun Tan" <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"youtux\@gmail.com" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-usb\@vger.kernel.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54811670.5030703-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org> (Kevin Zhu's message of "Fri, 5
	Dec 2014 02:20:36 +0000")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org> writes:

> Regarding the location of NDP, it should be easy to fix. It can be ad=
ded
> to the end of the NTB only after it's ready to send.

Yes, but this will require a bit of redesign.  Note that this code is
shared with cdc_mbim, which might have to add multiple NDPs for
multiplexed sessions.  In theory up to 512 different, but that is so
unlinkely that we can ignore it.  We could set a fixed limit
significantly lower than that if necessary.

I'd really like to refactor this code to simply queue the skbs, creatin=
g
the linear NTB only when the queue is flushed.  Then we'll have all the
info we need and can order the contents any way we want without adding
unnecessary padding.

> Regarding the
> concern to other devices, as there's a particular driver for Huawei
> devices in kernel, which is huawei_cdc_ncm, maybe we can just fix the=
 TX
> function there to avoid breaking other devices.

Sure.  That is definitely an alternative if we don't want to touch the
generic driver.

But making the generic driver flexible enough to accommodate any device
would be preferable.  I do hope we can do that.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
