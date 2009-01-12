From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: another race in hso
Date: Mon, 12 Jan 2009 14:52:57 +0100
Message-ID: <496B4B39.3090908@option.com>
References: <200812221454.57794.oliver@neukum.org> <496B44CD.5080702@option.com> <200901121436.16576.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200901121436.16576.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum wrote:
> Am Monday 12 January 2009 14:25:33 schrieb Denis Joseph Barrow:
>> Hi Oliver,
>> Correct me if I'm wrong but I probably am as usual but
>> this patch could be a lot more minimal, 70-80% of the patch seems to be
>> removing net_lock & serial_lock from hso_serial & hso_net
>> & adding lock to hso_device which to me appears to me to
>> have almost nothing to do with fixing the bug you found.
> 
> It is necessary to lock the new flags and the lock needs to be taken
> for both serial and net parts, therefore the existent locking scheme
> has to be changed.
> 
>> Admittedly seeing as the is_active flags are in the hso_device
>> structure it might make sense to have the lock there too
>> as it's common to hso_serial & hso_net.
>>
>>
>> You also changed is_active & usb_gone to chars rather than
>> leave them as u8's this is also unneccessary & even if I didnt write the
>> code I prefer u8's.
> 
> You can change that back, although if you need flags, you shouldn't
> use types that indicate a specific word length. That's outright evil.
Well chars are 1 byte in most architectures the most neutral bitfield
definition that most people go by for flags is unsigned int but I'll
stick with your definition so you don't need to repost the patch
unless there is a bug in it.
> 
>> Thanks for fixing the bug, I'll do a bit more examination of
>> the patch before applying it, how do the rest of you feel about the patch?
>> I personally would accept it as is if it passes a little testing.
> 
> Feel free to review and test.
> 
> 	Regards
> 		Oliver


-- 
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
 
T: +32 16 311 621
F: +32 16 207 164
d.barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
www.option.com

Disclaimer:
http://www.option.com/company/disclaimer.shtml
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
