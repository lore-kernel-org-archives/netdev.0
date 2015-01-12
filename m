From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4] can: Convert to runtime_pm
Date: Mon, 12 Jan 2015 14:53:04 +0100
Message-ID: <54B3D1C0.200@pengutronix.de>
References: <58f37b6fd9104ce185c413c473fe047b@BY2FFO11FD050.protection.gbl> <54AD267C.4060004@pengutronix.de> <12e7202e137e4d5680185748ebf0cf2d@BY2FFO11FD060.protection.gbl> <54B299A0.1000504@pengutronix.de> <bb20847c9546459592241f801be2b536@BY2FFO11FD027.protection.gbl> <54B3CB51.3060207@pengutronix.de> <4a61c12b2e1d4103a41a3faf1d58837a@BN1BFFO11FD030.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="M9Kn9GHlIsMmWac5OODndlmBw9xABM9OM"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Soren Brinkmann <sorenb@xilinx.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"wg@grandegger.com" <wg@grandegger.com>,
	Michal Simek <michals@xilinx.com>
To: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4a61c12b2e1d4103a41a3faf1d58837a@BN1BFFO11FD030.protection.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--M9Kn9GHlIsMmWac5OODndlmBw9xABM9OM
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/12/2015 02:49 PM, Appana Durga Kedareswara Rao wrote:
> Hi Marc,
>=20
>> -----Original Message-----
>> From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
>> Sent: Monday, January 12, 2015 6:56 PM
>> To: Appana Durga Kedareswara Rao
>> Cc: linux-can@vger.kernel.org; netdev@vger.kernel.org; linux-
>> kernel@vger.kernel.org; Soren Brinkmann; grant.likely@linaro.org;
>> wg@grandegger.com; Michal Simek
>> Subject: Re: [PATCH v4] can: Convert to runtime_pm
>>
>> On 01/12/2015 07:59 AM, Appana Durga Kedareswara Rao wrote:
>>> Hi Marc,
>>>
>>>> -----Original Message-----
>>>> From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
>>>> Sent: Sunday, January 11, 2015 9:11 PM
>>>> To: Appana Durga Kedareswara Rao
>>>> Cc: linux-can@vger.kernel.org; netdev@vger.kernel.org; linux-
>>>> kernel@vger.kernel.org; Soren Brinkmann; grant.likely@linaro.org;
>>>> wg@grandegger.com
>>>> Subject: Re: [PATCH v4] can: Convert to runtime_pm
>>>>
>>>> On 01/11/2015 06:34 AM, Appana Durga Kedareswara Rao wrote:
>>>> [...]
>>>>>>>             return ret;
>>>>>>>     }
>>>>>>>
>>>>>>>     priv->write_reg(priv, XCAN_MSR_OFFSET, 0);
>>>>>>>     priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_CEN_MASK);
>>>>>>>
>>>>>>>     if (netif_running(ndev)) {
>>>>>>>             priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>>>>>
>>>>>> What happens if the device was not in ACTIVE state prior to the
>>>>>> runtime_suspend?
>>>>>>
>>>>>
>>>>> I am not sure about the state of CAN at this point of time.
>>>>> I just followed what other drivers are following for run time  susp=
end :).
>>>>
>>>> Please check the state of the hardware if you go with bus off into
>>>> suspend and then resume.
>>>>
>>>
>>>         if (netif_running(ndev)) {
>>>                         if (isr & XCAN_IXR_BSOFF_MASK) {
>>>                                 priv->can.state =3D CAN_STATE_BUS_OFF=
;
>>>                            priv->write_reg(priv, XCAN_SRR_OFFSET,
>>>                                         XCAN_SRR_RESET_MASK);
>>>                 } else if ((status & XCAN_SR_ESTAT_MASK) =3D=3D
>>>                                         XCAN_SR_ESTAT_MASK) {
>>>                         priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
>>>                 } else if (status & XCAN_SR_ERRWRN_MASK) {
>>>                         priv->can.state =3D CAN_STATE_ERROR_WARNING;
>>>                 } else {
>>>                         priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>>                 }
>>>         }
>>>
>>> Is the above code snippet ok for you?
>>
>> Yes, but what's the state of the hardware when it wakes up again?
>=20
> It depends on the previous state of the CAN.
> I mean In Suspend we are putting the device in sleep mode and in resume=
 we are waking up by putting the device into the
> Configuration mode. We are not doing any reset of the core in the suspe=
nd/resume so it depends on the previous state of the CAN
> when it wakes up that's why  checking for the status of the CAN in the =
status register here to put the device in appropriate mode.

I understand the software side, but I don't know how your hardware
behaves. This is why I'm asking.

>=20
>>
>>>
>>>>>>>             netif_device_attach(ndev);
>>>>>>>             netif_start_queue(ndev);
>>>>>>>     }
>>>>>>>
>>>>>>>     return 0;
>>>>>>> }
>>>>>>
>>>>>>
>>>>>>>
>>>>>>> @@ -1020,9 +1035,9 @@ static int __maybe_unused
>> xcan_resume(struct
>>>>>>> device *dev)
>>>>>>>
>>>>>>>     priv->write_reg(priv, XCAN_MSR_OFFSET, 0);
>>>>>>>     priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_CEN_MASK);
>>>>>>> -   priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>>>>>>
>>>>>>>     if (netif_running(ndev)) {
>>>>>>> +           priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>>>>>>             netif_device_attach(ndev);
>>>>>>>             netif_start_queue(ndev);
>>>>>>>     }
>>>>>>> @@ -1030,7 +1045,10 @@ static int __maybe_unused
>>>> xcan_resume(struct
>>>>>> device *dev)
>>>>>>>     return 0;
>>>>>>>  }
>>>>>>>
>>>>>>> -static SIMPLE_DEV_PM_OPS(xcan_dev_pm_ops, xcan_suspend,
>>>>>> xcan_resume);
>>>>>>> +static const struct dev_pm_ops xcan_dev_pm_ops =3D {
>>>>>>> +   SET_SYSTEM_SLEEP_PM_OPS(xcan_suspend, xcan_resume)
>>>>>>> +   SET_PM_RUNTIME_PM_OPS(xcan_runtime_suspend,
>>>>>> xcan_runtime_resume,
>>>>>>> +NULL) };
>>>>>>>
>>>>>>>  /**
>>>>>>>   * xcan_probe - Platform registration call @@ -1071,7 +1089,7 @@=

>>>>>>> static int xcan_probe(struct platform_device *pdev)
>>>>>>>             return -ENOMEM;
>>>>>>>
>>>>>>>     priv =3D netdev_priv(ndev);
>>>>>>> -   priv->dev =3D ndev;
>>>>>>> +   priv->dev =3D &pdev->dev;
>>>>>>>     priv->can.bittiming_const =3D &xcan_bittiming_const;
>>>>>>>     priv->can.do_set_mode =3D xcan_do_set_mode;
>>>>>>>     priv->can.do_get_berr_counter =3D xcan_get_berr_counter; @@ -=

>>>>>> 1137,15
>>>>>>> +1155,22 @@ static int xcan_probe(struct platform_device *pdev)
>>>>>>>
>>>>>>>     netif_napi_add(ndev, &priv->napi, xcan_rx_poll, rx_max);
>>>>>>>
>>>>>>> +   pm_runtime_set_active(&pdev->dev);
>>>>>>> +   pm_runtime_irq_safe(&pdev->dev);
>>>>>>> +   pm_runtime_enable(&pdev->dev);
>>>>>>> +   pm_runtime_get_sync(&pdev->dev);
>>>>>> Check error values?
>>>>>
>>>>> Ok
>>>>>>> +
>>>>>>>     ret =3D register_candev(ndev);
>>>>>>>     if (ret) {
>>>>>>>             dev_err(&pdev->dev, "fail to register failed
>>>>>>> (err=3D%d)\n",
>>>>>> ret);
>>>>>>> +           pm_runtime_put(priv->dev);
>>>>>>
>>>>>> Please move the pm_runtime_put into the common error exit path.
>>>>>>
>>>>>
>>>>> Ok
>>>>>
>>>>>>>             goto err_unprepare_disable_busclk;
>>>>>>>     }
>>>>>>>
>>>>>>>     devm_can_led_init(ndev);
>>>>>>> -   clk_disable_unprepare(priv->bus_clk);
>>>>>>> -   clk_disable_unprepare(priv->can_clk);
>>>>>>> +
>>>>>>> +   pm_runtime_put(&pdev->dev);
>>>>>>> +
>>>>>>>     netdev_dbg(ndev, "reg_base=3D0x%p irq=3D%d clock=3D%d, tx fif=
o
>>>>>> depth:%d\n",
>>>>>>>                     priv->reg_base, ndev->irq, priv->can.clock.fr=
eq,
>>>>>>>                     priv->tx_max);
>>>>>>>
>>>>>>
>>>>>> I think you have to convert the _remove() function, too. Have a
>>>>>> look at the gpio-zynq.c driver:
>>>>>>
>>>>>>> static int zynq_gpio_remove(struct platform_device *pdev) {
>>>>>>>     struct zynq_gpio *gpio =3D platform_get_drvdata(pdev);
>>>>>>>
>>>>>>>     pm_runtime_get_sync(&pdev->dev);
>>>>>>
>>>>>> However I don't understand why the get_sync() is here. Maybe S=C3=B6=
ren
>>>>>> can help?
>>>>>
>>>>> I converted the remove function to use the run-time PM and .
>>>>> Below is the remove code snippet.
>>>>>
>>>>>        ret =3D pm_runtime_get_sync(&pdev->dev);
>>>>>         if (ret < 0) {
>>>>>                 netdev_err(ndev, "%s: pm_runtime_get failed(%d)\n",=

>>>>>                                 __func__, ret);
>>>>>                 return ret;
>>>>>         }
>>>>>
>>>>>         if (set_reset_mode(ndev) < 0)
>>>>>                 netdev_err(ndev, "mode resetting failed!\n");
>>>>>
>>>>>         unregister_candev(ndev);
>>>>>         netif_napi_del(&priv->napi);
>>>>>         free_candev(ndev);
>>>>
>>>>>         pm_runtime_disable(&pdev->dev);
>>>>
>>>> Can this make a call to xcan_runtime_*()? I'm asking since the ndev
>>>> has been unregistered and already free()ed. Better move this directl=
y
>>>> after the set_reset_mode(). This way you are symmetric to the probe(=
)
>> function.
>>>
>>> If I move the  pm_runtime_disable after the set_reset_mode I am
>>> getting the below error.
>>> ERROR:
>>> xilinx_can e0008000.can can0 (unregistering): xcan_get_berr_counter:
>>> pm_runtime_get fail
>>>
>>> If I move the pm_runtime_disable after unregister_candev everything i=
s
>> working fine.
>>
>> Fine - but who calls xcan_get_berr_counter here? Can you add a
>> dump_stack() here?
>>
>=20
> I think it is getting called from the atomic context.
> When I  am trying to do a rmmod I am getting the above error.
> ERROR:
> xilinx_can e0008000.can can0 (unregistering): xcan_get_berr_counter:
>  pm_runtime_get fail.
>=20
> I am getting only the above error in the console when I do rmmod.

Put a dump_stack into xcan_get_berr_counter(), then you'll see where
it's called from. However calling from atomic context should be fine.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--M9Kn9GHlIsMmWac5OODndlmBw9xABM9OM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUs9HAAAoJECte4hHFiupUIgMP/2fntKbjaZk2u63yakpiu6uX
UiU4qpCvAGbe1QmUtUAKdtOdZ5O5573Uv9mZ0RsK+gnOljH0pQL2eHUbfPPKGcSL
D8VQsDjzJb3doZZtlEaFDVXxEjOub8HzUtPlGb3Nmot/xjaRCRv3SPHLl8xS101Z
h8wFYxNBg5TOnLZFH/mRDtTwYnLLFRAh/88jLxHYEvHfCaA0tUDeDem1tiOBiR+U
jqw/F6IClYDHpPXHJ25D0qYLbeQpdcxLkzkV3NJxkgjev0Ybef7b9RyHY2Kv18bH
9ouejQJqyAd8zjMr31CKLHtpmGdlAV/odyhUGtDTKgrPAXOUGIdXmtGdx2qmlef2
Mf0arChP/BAsvrC4EaUbqTDOEySEhnoyZImKh5Zs+vwrRZVTqjeH3KoptfegA9X4
ew00pn/DlkbtDS0ho6GpAAyfTkxtPCiEWurSZIiSzidHi77E+f6ckIga6iTLOei1
JOevhOY10z0eClIy4GuC+y6KycmTvHu9h+cuHduDmt0/yy8ycUXiuU1yd3Czzyzj
Yv6KPc3rLvIdOHg3+Y1H64CBRYfCJrEFst7JPsyF72rIFAYzQwNeHmbj8t3rPW/z
5V4aG/jnq78WrR1KR3KmyLso+e8aKvLFW2+vyBrgIY00NHvNZ8sRKt7AM4E4//Cq
sWHInKp/HCYQmFBtxwO8
=PI+R
-----END PGP SIGNATURE-----

--M9Kn9GHlIsMmWac5OODndlmBw9xABM9OM--
