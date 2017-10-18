From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH v1 RFC 7/7] Modify tag_ksz.c so that tail tag code can
 be used by other KSZ switch drivers
Date: Wed, 18 Oct 2017 18:02:16 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD411319AD@CHN-SV-EXMX02.mchp-main.com>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
 <1507321985-15097-8-git-send-email-Tristram.Ha@microchip.com>
 <20171011204528.GA31288@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <ruediger.schmitt@philips.com>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011204528.GA31288@amd>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +#define KSZ9477_INGRESS_TAG_LEN		2
> > +#define KSZ9477_PTP_TAG_LEN		4
> > +#define KSZ9477_PTP_TAG_INDICATION	0x80
> > +
> > +#define KSZ9477_TAIL_TAG_OVERRIDE	BIT(9)
> > +#define KSZ9477_TAIL_TAG_LOOKUP		BIT(10)
> > +
> > +static int ksz9477_get_tag(u8 *tag, int *port)
> > +{
> > +	int len = KSZ_EGRESS_TAG_LEN;
> > +
> > +	/* Extra 4-bytes PTP timestamp */
> > +	if (tag[0] & KSZ9477_PTP_TAG_INDICATION)
> > +		len += KSZ9477_PTP_TAG_LEN;
> > +	*port = tag[0] & 7;
> > +	return len;
> > +}
> > +
> > +static void ksz9477_set_tag(void *ptr, u8 *addr, int p)
> > +{
> > +	u16 *tag = (u16 *)ptr;
> > +
> > +	*tag = 1 << p;
> > +	if (!memcmp(addr, special_mult_addr, ETH_ALEN))
> > +		*tag |= KSZ9477_TAIL_TAG_OVERRIDE;
> > +	*tag = cpu_to_be16(*tag);
> > +}
> 
> These are new features that were not there before, right?

Although it is the correct procedure, they will be removed until
this tail tag code has access to the main switch driver.
