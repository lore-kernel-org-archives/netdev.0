From: Fabio Porcedda <fabio.porcedda-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] net: qmi_wwan: fix checkpatch warnings
Date: Thu, 26 Sep 2013 11:06:37 +0200
Message-ID: <CAHkwnC-05BdptYjw0H+k=tc5fXq1Tc5pJyDQLGEvUZA5fy2NHQ@mail.gmail.com>
References: <1380100886-16531-1-git-send-email-fabio.porcedda@gmail.com>
 <1380100886-16531-2-git-send-email-fabio.porcedda@gmail.com> <877ge5own8.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <877ge5own8.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Bj=F8rn,
thanks for reviewing.

On Wed, Sep 25, 2013 at 3:31 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
> Sorry, I really don't see the point of this.  Yes, the lines are long=
er
> than 80 columns, but breaking them don't improve the readability at
> all.  On the contrary, IMHO.
>
> So NAK from me for this part.

Which changes do you think do not improve the readability?
I'm sure that at least some of them actually improve the readability.

Best regards
=46abio Porcedda

> Fabio Porcedda <fabio.porcedda-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>
>> Signed-off-by: Fabio Porcedda <fabio.porcedda-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>  drivers/net/usb/qmi_wwan.c | 56 +++++++++++++++++++++++++++++------=
-----------
>>  1 file changed, 36 insertions(+), 20 deletions(-)
>>
>> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
>> index 5f6b6fa..0e59f9e 100644
>> --- a/drivers/net/usb/qmi_wwan.c
>> +++ b/drivers/net/usb/qmi_wwan.c
>> @@ -143,16 +143,22 @@ static const struct net_device_ops qmi_wwan_ne=
tdev_ops =3D {
>>       .ndo_validate_addr      =3D eth_validate_addr,
>>  };
>>
>> -/* using a counter to merge subdriver requests with our own into a =
combined state */
>> +/* using a counter to merge subdriver requests with our own into a
>> + * combined state
>> + */
>>  static int qmi_wwan_manage_power(struct usbnet *dev, int on)
>>  {
>>       struct qmi_wwan_state *info =3D (void *)&dev->data;
>>       int rv =3D 0;
>>
>> -     dev_dbg(&dev->intf->dev, "%s() pmcount=3D%d, on=3D%d\n", __fun=
c__, atomic_read(&info->pmcount), on);
>> +     dev_dbg(&dev->intf->dev, "%s() pmcount=3D%d, on=3D%d\n", __fun=
c__,
>> +             atomic_read(&info->pmcount), on);
>>
>> -     if ((on && atomic_add_return(1, &info->pmcount) =3D=3D 1) || (=
!on && atomic_dec_and_test(&info->pmcount))) {
>> -             /* need autopm_get/put here to ensure the usbcore sees=
 the new value */
>> +     if ((on && atomic_add_return(1, &info->pmcount) =3D=3D 1) ||
>> +         (!on && atomic_dec_and_test(&info->pmcount))) {
>> +             /* need autopm_get/put here to ensure the usbcore sees
>> +              * the new value
>> +              */
>>               rv =3D usb_autopm_get_interface(dev->intf);
>>               if (rv < 0)
>>                       goto err;
>> @@ -199,7 +205,8 @@ static int qmi_wwan_register_subdriver(struct us=
bnet *dev)
>>       atomic_set(&info->pmcount, 0);
>>
>>       /* register subdriver */
>> -     subdriver =3D usb_cdc_wdm_register(info->control, &dev->status=
->desc, 4096, &qmi_wwan_cdc_wdm_manage_power);
>> +     subdriver =3D usb_cdc_wdm_register(info->control, &dev->status=
->desc,
>> +                                      4096, &qmi_wwan_cdc_wdm_manag=
e_power);
>>       if (IS_ERR(subdriver)) {
>>               dev_err(&info->control->dev, "subdriver registration f=
ailed\n");
>>               rv =3D PTR_ERR(subdriver);
>> @@ -228,7 +235,8 @@ static int qmi_wwan_bind(struct usbnet *dev, str=
uct usb_interface *intf)
>>       struct usb_driver *driver =3D driver_of(intf);
>>       struct qmi_wwan_state *info =3D (void *)&dev->data;
>>
>> -     BUILD_BUG_ON((sizeof(((struct usbnet *)0)->data) < sizeof(stru=
ct qmi_wwan_state)));
>> +     BUILD_BUG_ON((sizeof(((struct usbnet *)0)->data) <
>> +                   sizeof(struct qmi_wwan_state)));
>>
>>       /* set up initial state */
>>       info->control =3D intf;
>> @@ -250,7 +258,8 @@ static int qmi_wwan_bind(struct usbnet *dev, str=
uct usb_interface *intf)
>>                               goto err;
>>                       }
>>                       if (h->bLength !=3D sizeof(struct usb_cdc_head=
er_desc)) {
>> -                             dev_dbg(&intf->dev, "CDC header len %u=
\n", h->bLength);
>> +                             dev_dbg(&intf->dev, "CDC header len %u=
\n",
>> +                                     h->bLength);
>>                               goto err;
>>                       }
>>                       break;
>> @@ -260,7 +269,8 @@ static int qmi_wwan_bind(struct usbnet *dev, str=
uct usb_interface *intf)
>>                               goto err;
>>                       }
>>                       if (h->bLength !=3D sizeof(struct usb_cdc_unio=
n_desc)) {
>> -                             dev_dbg(&intf->dev, "CDC union len %u\=
n", h->bLength);
>> +                             dev_dbg(&intf->dev, "CDC union len %u\=
n",
>> +                                     h->bLength);
>>                               goto err;
>>                       }
>>                       cdc_union =3D (struct usb_cdc_union_desc *)buf=
;
>> @@ -271,15 +281,15 @@ static int qmi_wwan_bind(struct usbnet *dev, s=
truct usb_interface *intf)
>>                               goto err;
>>                       }
>>                       if (h->bLength !=3D sizeof(struct usb_cdc_ethe=
r_desc)) {
>> -                             dev_dbg(&intf->dev, "CDC ether len %u\=
n",  h->bLength);
>> +                             dev_dbg(&intf->dev, "CDC ether len %u\=
n",
>> +                                     h->bLength);
>>                               goto err;
>>                       }
>>                       cdc_ether =3D (struct usb_cdc_ether_desc *)buf=
;
>>                       break;
>>               }
>>
>> -             /*
>> -              * Remember which CDC functional descriptors we've see=
n.  Works
>> +             /* Remember which CDC functional descriptors we've see=
n.  Works
>>                * for all types we care about, of which USB_CDC_ETHER=
NET_TYPE
>>                * (0x0f) is the highest numbered
>>                */
>> @@ -293,10 +303,14 @@ next_desc:
>>
>>       /* Use separate control and data interfaces if we found a CDC =
Union */
>>       if (cdc_union) {
>> -             info->data =3D usb_ifnum_to_if(dev->udev, cdc_union->b=
SlaveInterface0);
>> -             if (desc->bInterfaceNumber !=3D cdc_union->bMasterInte=
rface0 || !info->data) {
>> -                     dev_err(&intf->dev, "bogus CDC Union: master=3D=
%u, slave=3D%u\n",
>> -                             cdc_union->bMasterInterface0, cdc_unio=
n->bSlaveInterface0);
>> +             info->data =3D usb_ifnum_to_if(dev->udev,
>> +                                          cdc_union->bSlaveInterfac=
e0);
>> +             if (desc->bInterfaceNumber !=3D cdc_union->bMasterInte=
rface0 ||
>> +                 !info->data) {
>> +                     dev_err(&intf->dev,
>> +                             "bogus CDC Union: master=3D%u, slave=3D=
%u\n",
>> +                             cdc_union->bMasterInterface0,
>> +                             cdc_union->bSlaveInterface0);
>>                       goto err;
>>               }
>>       }
>> @@ -374,8 +388,7 @@ static int qmi_wwan_suspend(struct usb_interface=
 *intf, pm_message_t message)
>>       struct qmi_wwan_state *info =3D (void *)&dev->data;
>>       int ret;
>>
>> -     /*
>> -      * Both usbnet_suspend() and subdriver->suspend() MUST return =
0
>> +     /* Both usbnet_suspend() and subdriver->suspend() MUST return =
0
>>        * in system sleep context, otherwise, the resume callback has
>>        * to recover device from previous suspend failure.
>>        */
>> @@ -383,7 +396,8 @@ static int qmi_wwan_suspend(struct usb_interface=
 *intf, pm_message_t message)
>>       if (ret < 0)
>>               goto err;
>>
>> -     if (intf =3D=3D info->control && info->subdriver && info->subd=
river->suspend)
>> +     if (intf =3D=3D info->control && info->subdriver &&
>> +         info->subdriver->suspend)
>>               ret =3D info->subdriver->suspend(intf, message);
>>       if (ret < 0)
>>               usbnet_resume(intf);
>> @@ -396,7 +410,8 @@ static int qmi_wwan_resume(struct usb_interface =
*intf)
>>       struct usbnet *dev =3D usb_get_intfdata(intf);
>>       struct qmi_wwan_state *info =3D (void *)&dev->data;
>>       int ret =3D 0;
>> -     bool callsub =3D (intf =3D=3D info->control && info->subdriver=
 && info->subdriver->resume);
>> +     bool callsub =3D (intf =3D=3D info->control && info->subdriver=
 &&
>> +                     info->subdriver->resume);
>>
>>       if (callsub)
>>               ret =3D info->subdriver->resume(intf);
>> @@ -777,7 +792,8 @@ static const struct usb_device_id products[] =3D=
 {
>>  };
>>  MODULE_DEVICE_TABLE(usb, products);
>>
>> -static int qmi_wwan_probe(struct usb_interface *intf, const struct =
usb_device_id *prod)
>> +static int qmi_wwan_probe(struct usb_interface *intf,
>> +                       const struct usb_device_id *prod)
>>  {
>>       struct usb_device_id *id =3D (struct usb_device_id *)prod;



--=20
=46abio Porcedda
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
