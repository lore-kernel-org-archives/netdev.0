From: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] usbnet: Activate the halt interrupt endpoint to fix
 endless "XactErr" error
Date: Tue, 12 Jun 2012 18:09:05 +0800
Message-ID: <CA+v9cxarz27iX=S9JUxW-oj_Q0+egRSjs1R2B36tyK1wYZFXHQ@mail.gmail.com>
References: <CA+v9cxYHq4gcy11SDmsuHUhTSdLJM-G0sugYnOjSthbYWA+1Yg@mail.gmail.com>
	<20120607.145438.1351539405712214173.davem@davemloft.net>
	<CA+v9cxaLERjFKdE7joGgmpbxCUotdh=Nn4F4f-KeOXwp8nqMPg@mail.gmail.com>
	<87sje1podo.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87sje1podo.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 12, 2012 at 4:47 AM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
> Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>
>> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
>> index 76f4396..c0bcb61 100644
>> --- a/include/linux/usb/usbnet.h
>> +++ b/include/linux/usb/usbnet.h
>> @@ -62,13 +62,14 @@ struct usbnet {
>> =A0 =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 flags;
>> =A0# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_TX_HALT =A0 =A00
>> =A0# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_RX_HALT =A0 =A01
>> -# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_RX_MEMORY =A02
>> -# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_STS_SPLIT =A03
>> -# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_LINK_RESET 4
>> -# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_RX_PAUSED =A05
>> -# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_WAKING 6
>> -# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_ASLEEP 7
>> -# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_OPEN =A0 8
>> +# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_STS_HALT =A0 2
>> +# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_RX_MEMORY =A03
>> +# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_STS_SPLIT =A04
>> +# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_LINK_RESET 5
>> +# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_RX_PAUSED =A06
>> +# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_WAKING 7
>> +# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_ASLEEP 8
>> +# =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_OPEN =A0 9
>> =A0};
>
> Why do you renumber all of these instead of adding the new
> EVENT_STS_HALT to the end of the list?
>

Thanks for your comments.

I think it's nice to sort these mask codes by their purposes.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
