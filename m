From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: phy address in the device tree, vs auto probing
Date: Wed, 10 Feb 2010 09:43:42 -0700
Message-ID: <fa686aa41002100843o7a1d4160q8fb01768ad48dcf4@mail.gmail.com>
References: <Acqp3tpO+gBYUakZQ7SaeBzVIkh6WA==>
	<4dfe033d-c308-45e0-9c7e-9fc60c6cad8f@SG2EHSMHS013.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: John Linn <John.Linn-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	devicetree-discuss <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <4dfe033d-c308-45e0-9c7e-9fc60c6cad8f-RaUQJvECHivT7m58JnLnSLjjLBE8jN/0@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

(cc'ing devicetree-discuss and netdev mailing lists)

On Tue, Feb 9, 2010 at 4:23 PM, John Linn <John.Linn-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org> wrote:
> Hi Grant,
>
> I notice that the OF driver for the mdio bus is not doing auto probing.
>
> As we start putting in the phy layer in the emac drivers, the device
> trees tend to have the phy address in them, but we're not sure we really
> like that.
>
> We really think that being able to let the kernel find the phy address
> is a big benefit, otherwise this is one other piece of info the user has
> to know and get right.
>
> Am I missing something here?

No, you're not really missing something, but there is an inherent
complexity in what you're wanting to do.  Like i2c, MDIO is one of
those busses that is hard to probe reliable.  Some PHYs respond on
more than one address, and there is no way to determine which MAC a
PHY is wired up to.  Many PHYs can live on a single MDIO bus.  MACs
with their own MDIO busses may still get wired to a PHY on a different
bus.

In the simple case where there is a one:one:one relationship between
MAC, MDIO bus and PHY, then it should be okay to probe the PHY,
correct?  The question then must be asked; how does the kernel
determine that it can use the simple case?  Nobody has yet defined a
way to describe that in the device tree; mostly because nobody has
needed to yet.

So, it is possible to do what you want, but you need a way to
*explicitly* ask for that behaviour.  ie, some way to indicate in a
MAC node which MDIO bus the phy is on, and that the phy needs to be
probed for.  I think this should only be an option when the MDIO bus
has only one PHY.  Come up with a proposal and post it to the
devicetree-discuss mailing list.

g.

>
> Thanks,
> John
>
>
> int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
> {
> =A0 =A0 =A0 =A0struct phy_device *phy;
> =A0 =A0 =A0 =A0struct device_node *child;
> =A0 =A0 =A0 =A0int rc, i;
>
> =A0 =A0 =A0 =A0/* Mask out all PHYs from auto probing. =A0Instead the PHY=
s listed
> in
> =A0 =A0 =A0 =A0 * the device tree are populated after the bus has been
> registered */
> =A0 =A0 =A0 =A0mdio->phy_mask =3D ~0;
>
> This email and any attachments are intended for the sole use of the named=
 recipient(s) and contain(s) confidential information that may be proprieta=
ry, privileged or copyrighted under applicable law. If you are not the inte=
nded recipient, do not read, copy, or forward this email message or any att=
achments. Delete this email message and any attachments immediately.
>
>
>



-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
