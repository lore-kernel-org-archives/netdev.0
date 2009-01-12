From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: another race in hso
Date: Mon, 12 Jan 2009 14:36:14 +0100
Message-ID: <200901121436.16576.oliver@neukum.org>
References: <200812221454.57794.oliver@neukum.org> <496B44CD.5080702@option.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Paul Hardwick <P.Hardwick-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>, ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org,
	"Greg Kroah-Hartman" <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <496B44CD.5080702-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Monday 12 January 2009 14:25:33 schrieb Denis Joseph Barrow:
> Hi Oliver,
> Correct me if I'm wrong but I probably am as usual but
> this patch could be a lot more minimal, 70-80% of the patch seems to be
> removing net_lock & serial_lock from hso_serial & hso_net
> & adding lock to hso_device which to me appears to me to
> have almost nothing to do with fixing the bug you found.

It is necessary to lock the new flags and the lock needs to be taken
for both serial and net parts, therefore the existent locking scheme
has to be changed.

> Admittedly seeing as the is_active flags are in the hso_device
> structure it might make sense to have the lock there too
> as it's common to hso_serial & hso_net.
> 
> 
> You also changed is_active & usb_gone to chars rather than
> leave them as u8's this is also unneccessary & even if I didnt write the
> code I prefer u8's.

You can change that back, although if you need flags, you shouldn't
use types that indicate a specific word length. That's outright evil.

> Thanks for fixing the bug, I'll do a bit more examination of
> the patch before applying it, how do the rest of you feel about the patch?
> I personally would accept it as is if it passes a little testing.

Feel free to review and test.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
