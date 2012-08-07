From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v3 3/7] mv643xx.c: Add basic device tree support.
Date: Tue, 7 Aug 2012 20:25:22 +0000
Message-ID: <201208072025.22871.arnd@arndb.de>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk>
 <201208071456.41412.arnd@arndb.de> <50213ACB.6040301@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
 ben.dooks-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ian Molton <ian.molton-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>,
 "linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Dale Farnsworth <dale-1viX+2+OPRFcxvNqPlePQg@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <50213ACB.6040301-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Tuesday 07 August 2012, Ian Molton wrote:
> > I think it documents some of the same thing,
> 
> Not really. It documents some godawful hack that recycled the platform
> device -based driver and provided a DT binding for it, just for PPC.
> 
> I cant even find anything that implements code for whatever
> "marvell,mv64360-mdio" might be. I'm sure it might exist somewhere.

The code dates back to when we had separate buses for platform devices
and of devices, and then it was decided not to add support for both
bus types to each of the marvell drivers. In hindsight it would have
been better to do that, but that was impossible to tell back then.

> > We might also want to move some of the
> > code from arch/powerpc/sysdev/mv64x60_dev.c to live in the same place
> > as the device driver.
> 
> I hope not. I don't really want to touch that stuff at all. If it works
> the way it
> is, then it can stay that way. If the PPC folk want to send patches to
> add the
> properties they use to the driver, then they can do. I'll send an email
> their
> way and see if they want to join in.
> 
> From my perspective, the next thing that needs to happen to the driver is
> for it to be broken up into ethernet and mdio drivers, so that we can
> get rid
> of all this shared_smi craziness... But that's for another patch series.

Adding devicetree-discuss and linuxppc-dev, as well as Dale Farnsworth,
who initially added the bindings for mv643xx.

I would hope that at least some of the properties that are used on
powerpc can be reused in the same way for other architectures.
The method to find the phy address on powerpc does indeed make
more sense than the "port_number" property you suggested, and the
phandle for the phy node is usually called "phy" not "mdio".

I'm not sure if the ethernet-group is required on ARM as well, but
it does sound a lot like what you actually want instead of the
shared_smi property.

	Arnd
