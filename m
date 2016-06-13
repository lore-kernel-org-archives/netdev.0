From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: [PATCH 3/5] ARM: sun8i: dt: Add DT bindings
 documentation for Allwinner sun8i-emac
Date: Mon, 13 Jun 2016 15:43:15 +0800
Message-ID: <CAGb2v66y8AbQppGmaxJeVsfE0OvG5WMW-HuDAivFu96XN2pLAQ@mail.gmail.com>
References: <1464947790-22991-1-git-send-email-clabbe.montjoie@gmail.com>
 <1464947790-22991-4-git-send-email-clabbe.montjoie@gmail.com>
 <20160606141438.GA9510@rob-hp-laptop> <5755BCAE.6060307@gmail.com> <20160608191133.GA14655@rob-hp-laptop>
Reply-To: wens-jdAy2FN1RRM@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Corentin LABBE <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBKWI7G5AKGQEC3EA3HQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20160608191133.GA14655@rob-hp-laptop>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Hi Rob,

On Thu, Jun 9, 2016 at 3:11 AM, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> On Mon, Jun 06, 2016 at 08:10:54PM +0200, Corentin LABBE wrote:
>> Le 06/06/2016 16:14, Rob Herring a =C3=A9crit :
>> > On Fri, Jun 03, 2016 at 11:56:28AM +0200, LABBE Corentin wrote:
>> >> This patch adds documentation for Device-Tree bindings for the
>> >> Allwinner sun8i-emac driver.
>> >>
>> >> Signed-off-by: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> >> ---
>> >>  .../bindings/net/allwinner,sun8i-emac.txt          | 64 ++++++++++++=
++++++++++
>> >>  1 file changed, 64 insertions(+)
>> >>  create mode 100644 Documentation/devicetree/bindings/net/allwinner,s=
un8i-emac.txt
>> >>
>> >> diff --git a/Documentation/devicetree/bindings/net/allwinner,sun8i-em=
ac.txt b/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
>> >> new file mode 100644
>> >> index 0000000..cf71a71
>> >> --- /dev/null
>> >> +++ b/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
>> >> @@ -0,0 +1,64 @@
>> >> +* Allwinner sun8i EMAC ethernet controller
>> >> +
>> >> +Required properties:
>> >> +- compatible: "allwinner,sun8i-a83t-emac", "allwinner,sun8i-h3-emac"=
,
>> >> +          or "allwinner,sun50i-a64-emac"
>> >> +- reg: address and length of the register sets for the device.
>> >> +- reg-names: should be "emac" and "syscon", matching the register se=
ts
>> >
>> > Is syscon shared with other devices? Your example only has 1 reg
>> > address.
>> >
>>
>> The example is bad, emac and syscon are two distinct regspaces.
>> I will correct the example.
>
> And the syscon registers are not shared with anything else? Typically,
> syscon registers would be a separate node not part of this blocks
> registers. The main thing is make sure you are not creating overlapping
> register addresses.

These syscon registers are in a separate address range, like a glue layer
over the underlying EMAC hardware. There are only 2 registers defined in
that address range, and this particular one is used only for EMAC related
controls.

The other register is not used anywhere in the kernel. It's a readonly
register that gives the SoC revision. IIRC there was some work to add
per-platform functions to support this, but we haven't the need to use
it yet.

Hope this clears things up.

Regards
ChenYu

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
