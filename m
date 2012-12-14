From: Steve Glendinning <steve-nksJyM/082jR7s880joybQ@public.gmane.org>
Subject: Re: [PATCHv2][RFC] smsc95xx: enable dynamic autosuspend
Date: Fri, 14 Dec 2012 13:38:01 +0000
Message-ID: <CAKh2mn7+OpvUqu5u5pnDwUHUXEf7wfbdBZ8uKf=jh6OOCqbojw@mail.gmail.com>
References: <1355239561-2740-1-git-send-email-steve.glendinning@shawell.net>
	<1355243276.24219.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1355243276.24219.3.camel@joe-AO722>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11 December 2012 16:27, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> On Tue, 2012-12-11 at 15:26 +0000, Steve Glendinning wrote:
> []> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> []
>> +     ret = smsc95xx_read_reg_nopm(dev, RX_FIFO_INF, &val);
>> +     if (ret < 0) {
>> +             netdev_warn(dev->net, "Error reading RX_FIFO_INF");
>
> Please remember terminating newlines.

Oops, I've fixed this now in my tree.

> If you are always going to warn bad reads or writes,
> it'd be good to change smsc95xx_read_reg_nopm
> and write to emit the message.
>
> It saves ~3% of code, 1K
> $ size drivers/net/usb/smsc95xx.o*
>    text    data     bss     dec     hex filename
>   27064    2724    6072   35860    8c14 drivers/net/usb/smsc95xx.o.new
>   27921    2724    6256   36901    9025 drivers/net/usb/smsc95xx.o.old
>
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

Thanks for this Joe, actually as the register access functions already
print a warning with the register number I don't think we need to log
this at the calling site at all.  I'll rip out all the warnings that
don't add any significant new information (i.e. *why* the call may
have failed, or what its failure means).

--
Steve Glendinning
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
