From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: Re: [PATCH 04/10] net: stmmac: sunxi platfrom
 extensions for GMAC in Allwinner A20 SoC's
Date: Tue, 7 Jan 2014 18:24:55 +0800
Message-ID: <CAGb2v67iSZOivEokrye7haQss06MvUaPCNGF=E+odasgzhoWFg@mail.gmail.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-5-git-send-email-wens@csie.org> <52A5A52C.50605@st.com>
 <CAGb2v67WiCaMpJEzA_X6o7uOu6i3w3FCEz7=N5HY0amQb01SZA@mail.gmail.com>
 <52A72C6D.60100@st.com> <CAGb2v64qQvqJSicA6MTAxeh1sGjWY=Pk=vDq=9J3pTQW+wkXrA@mail.gmail.com>
 <52A87A74.8040807@st.com> <20131212090415.GQ3651@lukather>
 <CAGb2v655_83b76PTmgkDmNGCADWwTjTwW13sOgM5HFmCVkeu=w@mail.gmail.com>
 <20131213103822.GX3651@lukather> <CAGb2v64Q1PSMw_nULBHMR5eOC44hWBPewchxE_4sO+4XN8_sDA@mail.gmail.com>
 <52C5656A.4060402@st.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: srinivas kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBDNMV6LAKGQETPFF6KY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <52C5656A.4060402-qxv4g6HH51o@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Jan 2, 2014 at 9:11 PM, srinivas kandagatla
<srinivas.kandagatla-qxv4g6HH51o@public.gmane.org> wrote:
> Hi Chen,
>
> On 24/12/13 03:27, Chen-Yu Tsai wrote:
>> Srinivas,
>>
>> Let's keep platform data as of_data, so SoC compatibles can pass
>> hardware feature flags for cores that don't support auto-detection.
>
> I understand your concern here, But making platform_data as of_data
> would just open a wide door for other hacky stuff too. So other glue
> drivers would just use this interface instead, ignoring standard
> interfaces. Also there would be issues on who takes the priority if the
> parameters are specified in multiple places.
>
>
> Can't this field/s be one of the variable in the struct stmmac_of_data
> rather than reusing platform data?

We (sunxi) need .has_gmac and .tx_coe.

To be generic and usable to other SoCs, it seems like I would be
adding most of the fields from platform data. But maybe future
glue layers will only need the callbacks. I can not be sure.

Also since snps,phy-addr should be deprecated, I am thinking of
changing the default phy address to auto-detect, until
Giuseppe merges his phy node support work.

I will post a v2 series this week.

>>
>> We can adjust the callbacks as you suggested, and I added a .free
>> to complement .setup. Driver private data and platform data are
>> off limits to the callbacks. My version of the callbacks:
>>
>>         void (*fix_mac_speed)(void *priv, unsigned int speed);
>>         void (*bus_setup)(void __iomem *ioaddr);
>
> In reply to your question in last email:
> bus_setup this is something very specific to ST which configures the bus
> parameters of AMBA-to-STBUS converter. This register falls inside the
> memory map of stmmac.

I see. IMHO it could be merged into .init?

>
>>         void *(*setup)(struct platform_device *pdev);
>>         void (*free)(struct platform_device *pdev, void *priv);
>>         int (*init)(struct platform_device *pdev, void *priv);
>>         void (*exit)(struct platform_device *pdev, void *priv);
>>
>
> The callbacks to Ok to me, unless Peppe has more comments on this.

Ok.


Cheers
ChenYu
