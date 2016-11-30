From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net] cdc_ether: Fix handling connection notification
Date: Wed, 30 Nov 2016 22:59:32 +0100
Message-ID: <CAKfDRXjfHWyrFbWjffdWBZj2KXb+bnoDu9oHrcU40=XWe7fBjw@mail.gmail.com>
References: <20161130184216.4224-1-kristian.evensen@gmail.com> <87shq83acr.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Oliver Neukum <oliver@neukum.org>, linux-usb@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org,
        Henning Schild <henning.schild@siemens.com>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87shq83acr.fsf@miraculix.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 30, 2016 at 10:51 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
> Kristian Evensen <kristian.evensen@gmail.com> writes:
>
>> +void usbnet_cdc_zte_status(struct usbnet *dev, struct urb *urb)
>> +{
>> +     struct usb_cdc_notification *event;
>> +
>> +     if (urb->actual_length < sizeof(*event))
>> +             return;
>> +
>> +     event =3D urb->transfer_buffer;
>> +
>> +     if (event->bNotificationType !=3D USB_CDC_NOTIFY_NETWORK_CONNECTIO=
N) {
>> +             usbnet_cdc_status(dev, urb);
>> +             return;
>> +     }
>> +
>> +     netif_dbg(dev, timer, dev->net, "CDC: carrier %s\n",
>> +               event->wValue ? "on" : "off");
>> +
>> +     if (event->wValue &&
>> +         !test_bit(__LINK_STATE_NOCARRIER, &dev->net->state))
>> +             usbnet_link_change(dev, 0, 0);
>> +
>> +     usbnet_link_change(dev, !!event->wValue, 0);
>> +}
>
> As Henning said: Use netif_carrier_ok instead of open coding it.
>
> But I also think you need to replace the first usbnet_link_change() with
> a plain netif_carrier_off(dev->net).  Calling usbnet_link_change() twice
> here is only going to set off the "kevent XX may have been dropped"
> message since you call schedule_work() twice without giving the work
> queue a chance to be processed.  No need to do that.

Thanks for the feedback and agree. Will submit a v2 tomorrow.

-Kristian
