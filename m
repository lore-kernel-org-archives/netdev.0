From: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] usbnet: Activate the halt interrupt endpoint to fix
 endless "XactErr" error
Date: Sat, 9 Jun 2012 00:36:23 +0800
Message-ID: <CA+v9cxYt29H38pY-6n=hn90i-q7FJAGAa1_Coss4akK_4C0ZHA@mail.gmail.com>
References: <CA+v9cxag9NV2ud+oupyziLN3nLgkgj+kyTcaOnEjYNjqXtM4Bw@mail.gmail.com>
	<Pine.LNX.4.44L0.1206081212150.1360-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.1206081212150.1360-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 9, 2012 at 12:13 AM, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>=
 wrote:
> On Fri, 8 Jun 2012, Huajun Li wrote:
>
>> > One possibility is to wait for a little while before resubmitting =
the
>> > URB, and after 10 failures in a row, attempt a reset.
>> >
>> Alan, thanks for your proposal.
>> You mean reset the device after 10 failures, right ?
>
> Yes. =A0But I don't know if it will help your problem.
>

usb_queue_reset_device() could make it work again, I ever tried this.

And I tried usb_clear_halt() and found this also made it work, so
drafted this patch.

>> BTW, I ever tried to sleep several seconds before submitting the 1st
>> interrupt URB, but it did not work.
>
> As Ming Lei said, it sounds like your device isn't working right.
>

Yes.
However, if add a quirk to fix the issue,  I did not find a elegant
solution, at least based on current usbnet/cdc_ether framework.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
