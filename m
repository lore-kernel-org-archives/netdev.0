From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 4/6] net: ethernet: bgmac: convert to feature flags
Date: Tue, 20 Sep 2016 07:19:19 +0200
Message-ID: <CACna6rymVcKV1h_PEvRuCQrtOd4rsqV34bMWzVOof15fdc8KEA@mail.gmail.com>
References: <1467932938-21819-1-git-send-email-jon.mason@broadcom.com>
 <1467932938-21819-5-git-send-email-jon.mason@broadcom.com> <CACna6rw1j3myPEkbn+YR71W7CF7Of_yahn9eDT7t3hKWGmWUmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
        Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Ray Jui <rjui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Scott Branden <sbranden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        bcm-kernel-feedback-list <bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACna6rw1j3myPEkbn+YR71W7CF7Of_yahn9eDT7t3hKWGmWUmg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 17 August 2016 at 13:34, Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrot=
e:
> On 8 July 2016 at 01:08, Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
>>         mode =3D (bgmac_read(bgmac, BGMAC_DEV_STATUS) & BGMAC_DS_MM_MASK=
) >>
>>                 BGMAC_DS_MM_SHIFT;
>> -       if (ci->id !=3D BCMA_CHIP_ID_BCM47162 || mode !=3D 0)
>> +       if (bgmac->feature_flags & BGMAC_FEAT_CLKCTLST || mode !=3D 0)
>>                 bgmac_set(bgmac, BCMA_CLKCTLST, BCMA_CLKCTLST_FORCEHT);
>> -       if (ci->id =3D=3D BCMA_CHIP_ID_BCM47162 && mode =3D=3D 2)
>> +       if (bgmac->feature_flags & BGMAC_FEAT_CLKCTLST && mode =3D=3D 2)
>>                 bcma_chipco_chipctl_maskset(&bgmac->core->bus->drv_cc, 1=
, ~0,
>>                                             BGMAC_CHIPCTL_1_RXC_DLL_BYPA=
SS);
>
> Jon, it looks to me you translated two following conditions:
> ci->id !=3D BCMA_CHIP_ID_BCM47162
> and
> ci->id =3D=3D BCMA_CHIP_ID_BCM47162
> into the same flag check:
> bgmac->feature_flags & BGMAC_FEAT_CLKCTLST
>
> I don't think it's intentional, is it? Do you have a moment to fix this?

Ping

--=20
Rafa=C5=82
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
