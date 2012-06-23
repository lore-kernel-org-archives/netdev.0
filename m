From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Gobi device probing
Date: Sat, 23 Jun 2012 11:26:54 +0200
Message-ID: <87y5neidk1.fsf@nemi.mork.no>
References: <1340282758-18085-1-git-send-email-bjorn@mork.no>
	<20120622.171735.637204872051168180.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	H.Siebmanns-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120622.171735.637204872051168180.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David
	Miller's message of "Fri, 22 Jun 2012 17:17:35 -0700 (PDT)")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> From: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> Date: Thu, 21 Jun 2012 14:45:58 +0200
>
>> Ignoring interfaces with additional descriptors is not a reliable
>> method for locating the correct interface on Gobi devices.  There
>> is at least one device where this method fails:
>> https://bbs.archlinux.org/viewtopic.php?id=3D143506
>>=20
>> The result is that the AT command port (interface #2) is hidden
>> from qcserial, preventing traditional serial modem usage:
>  ...
>> Use static interface numbers taken from the interface map in
>> qcserial for all Gobi devices instead:
>  ...
>> This should be more reliable over all, and will also prevent the
>> noisy "probe failed" messages.  The whitelisting logic is expected
>> to be replaced by direct interface number matching in 3.6.
>>=20
>> Reported-by: Heinrich Siebmanns (Harvey) <H.Siebmanns-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
>> Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # v3.4: 0000188 USB: qmi_wwan: Make for=
ced int 4 whitelist generic
>> Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # v3.4: f7142e6 USB: qmi_wwan: Add ZTE =
(Vodafone) K3520-Z
>> Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # v3.4
>> Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
>
> Applied.

Thanks.

Note that this patch will conflict with the qmi_wwan changes already in
net-next.  I can prepare a minimal forward port if you like.

But I would really prefer to rewrite it completely for 3.6 instead,
taking advantage of the USB interface number matching in usb-next.  Tha=
t
will allow us to get rid of the ugly whitelisting logic and just match
directly on the USB interface number instead.  Would that be OK?  It
will depend on=20

 81df2d5 USB: allow match on bInterfaceNumber
 fec1868 USB: properly pad out usb_device_id.driver_info

from usb-next, so those must go into net-next before this is possible.
Is waiting for 3.6-rc1 the best alternative, or is cherry-picking them
an option?

I can of course also do the basic forward port now and then fix it up
later during the 3.6 cycle if you prefer that.



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
