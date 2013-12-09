From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: Re: [PATCH 04/10] net: stmmac: sunxi platfrom
 extensions for GMAC in Allwinner A20 SoC's
Date: Mon, 9 Dec 2013 23:45:13 +0800
Message-ID: <CAGb2v65T4jqvrW=ZX3fcEm22rU0DEgsRJ2NtXDQ2406Ou5G9MA@mail.gmail.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-5-git-send-email-wens@csie.org> <52A5A7B2.4000509@st.com> <52A5C950.7070903@cogentembedded.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: srinivas kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBHOLS6KQKGQELAV7RJQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <52A5C950.7070903-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi,

On Mon, Dec 9, 2013 at 9:44 PM, Sergei Shtylyov
<sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org> wrote:
> Hello.
>
>
> On 09-12-2013 15:21, srinivas kandagatla wrote:
>
>>> +static int sun7i_gmac_init(struct platform_device *pdev)
>>> +{
>>> +       struct resource *res;
>>> +       struct device *dev = &pdev->dev;
>>> +       void __iomem *addr = NULL;
>>> +       struct plat_stmmacenet_data *plat_dat = NULL;
>
>
>    No need to initialize it since you're assigning to it right below.
>
>
>>> +       u32 priv_clk_reg;
>>> +
>>> +       plat_dat = dev_get_platdata(&pdev->dev);
>>> +       if (!plat_dat)
>>> +               return -EINVAL;
>
>
>> dev_get_platdata will return NULL for DT, So this function will fail all
>> the time.
>
>
>    Indeed, unless the probe() method assigns it from the 'data' field of
> 'struct of_device_id'.
>
>
>> How is it supposed to work?
>> Am I missing some thing?
>
>
>    Look at stmmac_pltfr_probe().

Actually, Srinivas is right.
The platform data assigned from the 'data field' is not the same one as
dev_get_platdata().

This is something I missed when I was reworking the patches.


ChenYu
