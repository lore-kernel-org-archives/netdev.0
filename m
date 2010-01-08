From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] drivers/net/skfp/skfddi.c: use %pMF to show MAC address
Date: Fri, 8 Jan 2010 15:57:23 +0100
Message-ID: <e2d7436a1001080657r138012d9y1d242e8f3d1568ce@mail.gmail.com>
References: <201001071627.46569.hartleys@visionengravers.com>
	 <20100108000224.GH2436@verge.net.au>
	 <1262915005.10429.92.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Horman <horms@verge.net.au>,
	H Hartley Sweeten <hartleys@visionengravers.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:34417 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753443Ab0AHO5Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 09:57:25 -0500
In-Reply-To: <1262915005.10429.92.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/1/8 Joe Perches <joe@perches.com>:
> On Fri, 2010-01-08 at 11:02 +1100, Simon Horman wrote:
>> On Thu, Jan 07, 2010 at 04:27:46PM -0700, H Hartley Sweeten wrote:
>> > Use the %pMF kernel extension to display the MAC address.
>> > The address will still be displayed in the FDDI Canonical format.
>> I'm not sure that it matters, but prior to this patch
>> the address was displayed with octets delimited by spaces,
>> and afterwards its delimited by hyphens. So perhaps the comment
>> should read:
>>
>> The address will now be displayed in the FDDI Canonical format.
> And it probably wasn't bit reversed.
>> > diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
>> > index db216a7..1f9698c 100644
>> > --- a/drivers/net/skfp/skfddi.c
>> > +++ b/drivers/net/skfp/skfddi.c
>> > @@ -435,13 +435,7 @@ static =A0int skfp_driver_init(struct net_dev=
ice *dev)
>> > =A0 =A0 =A0 =A0 =A0 =A0 goto fail;
>> > =A0 =A0 }
>> > =A0 =A0 read_address(smc, NULL);
>> > - =A0 pr_debug(KERN_INFO "HW-Addr: %02x %02x %02x %02x %02x %02x\n=
",
>> > - =A0 =A0 =A0 =A0 =A0smc->hw.fddi_canon_addr.a[0],
>> > - =A0 =A0 =A0 =A0 =A0smc->hw.fddi_canon_addr.a[1],
>> > - =A0 =A0 =A0 =A0 =A0smc->hw.fddi_canon_addr.a[2],
>> > - =A0 =A0 =A0 =A0 =A0smc->hw.fddi_canon_addr.a[3],
>> > - =A0 =A0 =A0 =A0 =A0smc->hw.fddi_canon_addr.a[4],
>> > - =A0 =A0 =A0 =A0 =A0smc->hw.fddi_canon_addr.a[5]);
>> > + =A0 pr_debug(KERN_INFO "HW-Addr: %pMF\n", smc->hw.fddi_canon_add=
r.a);
> Is fddi_canon_addr already bit reversed?
> It's memcpy'd to dev->dev_addr later, so probably not.
>
>> > =A0 =A0 smt_reset_defaults(smc, 0);
>> > @@ -890,15 +884,8 @@ static void skfp_ctl_set_multicast_list_wo_lo=
ck(struct net_device *dev)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (struct fddi_addr *)dmi->dmi_a=
ddr,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1);
>> >
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 pr_debug(KERN_INFO "ENABLE MC ADDRESS:");
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 pr_debug(" %02x %02x %02x ",
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0dmi->dmi_addr[0],
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0dmi->dmi_addr[1],
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0dmi->dmi_addr[2]);
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 pr_debug("%02x %02x %02x\n",
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0dmi->dmi_addr[3],
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0dmi->dmi_addr[4],
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0dmi->dmi_addr[5]);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 pr_debug(KERN_INFO "ENABLE MC ADDRESS: %pMF\n",
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 dmi->dmi_addr);
> I think you want %pM here, not the bit-reversed %pMF form.

You could add %pMf for those, that are bit-reversed already? That
should take at most two extra insns for x86. ;)

Best Regards,
Micha=B3 Miros=B3aw
