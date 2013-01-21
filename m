From: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] CDC_NCM: adding support FLAG_NOARP for Infineon modem
 platform
Date: Mon, 21 Jan 2013 15:33:00 +0400
Message-ID: <50FD276C.5010608@mvista.com>
References: <1358662329-8294-1-git-send-email-cpuwolf@gmail.com> <1358662329-8294-2-git-send-email-cpuwolf@gmail.com> <50FC25B7.70708@mvista.com> <CACa7zynymtYN4OtTjVNTNdB23eNU4D-G+JqaTxjaPFekRHkRAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, peter-Y+HMSxxDrH8@public.gmane.org,
	oneukum-l3A5Bk7waGM@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACa7zynymtYN4OtTjVNTNdB23eNU4D-G+JqaTxjaPFekRHkRAg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 21-01-2013 6:20, Wei Shuai wrote:

> The main problem is that these devices don't support ethernet.  They
> support IP (v4 and _maybe_ v6) with an ethernet header.  Many of them
> will do ARP (and IPv6 ND) as well to complete the picture, but some of
> them don't and that's what these drivers try to deal with.
>
> Note that most of the devices will run a DHCP server, so there is some
> sort of IP broadcast support.  Whether that qualifies as proper ethernet
> broadcast support is another question...
>
> These devices are attempting to bridge an IP-only point-to-point
> interface and an ethernet over USB interface, with the intention to make
> the point-to-point interface look like ethernet to applications and
> users. This is of course always going to be imperfect.  But I believe
> that we should aim to help the firmware achive this goal when writing
> drivers instead of working against it.  Setting IFF_NOARP and not
> IFF_POINTTOPOINT is one way to do that. ---- by  Bjorn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

    Why are you replying with this long story to my simple patch comments? :-)

> 2013/1/21, Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>:
>> Hello.

>> On 20-01-2013 10:12, Wei Shuai wrote:

>>> Infineon(now Intel) HSPA Modem platform NCM cannot support ARP. we can
>>> define a new common structure wwan_noarp_info.

>>      Wrap your lines at 76-80 columns maximum please.

>>> Then more similiar NO ARP devices can be handled easily

    s/NO/no/.

>>> Signed-off-by: Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> ---
>>>    drivers/net/usb/cdc_ncm.c |   21 +++++++++++++++++++++
>>>    1 files changed, 21 insertions(+), 0 deletions(-)

>>> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
>>> index 71b6e92..2d699b6 100644
>>> --- a/drivers/net/usb/cdc_ncm.c
>>> +++ b/drivers/net/usb/cdc_ncm.c
>>> @@ -1155,6 +1155,20 @@ static const struct driver_info wwan_info = {
>>>    	.tx_fixup = cdc_ncm_tx_fixup,
>>>    };
>>>
>>> +/* Same as wwan_info, but with IFF_NOARP  */

>>      FLAG_NOARP, you mean?

>>> +static const struct driver_info wwan_noarp_info = {
>>> +	.description = "Mobile Broadband Network Device (NO ARP)",
>>> +	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET
>>> +			| FLAG_WWAN | FLAG_NOARP,

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
