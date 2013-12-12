From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: [PATCH 01/10] net: stmmac: Enable stmmac main clock
 when probing hardware
Date: Thu, 12 Dec 2013 12:31:53 +0800
Message-ID: <CAGb2v67TkxcMSrFsMtAy8TaMG_VZWt73xZZcuqkJ71VO4y=7_w@mail.gmail.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-2-git-send-email-wens@csie.org> <20131207103335.GL24519@lukather>
 <CAGb2v65YOSq_BMWSzSHX8w_hbo+0vwquBT2pnLuwNVZkWRfLvA@mail.gmail.com> <20131210200529.GD3651@lukather>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBTXYUSKQKGQE4RI3AYI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20131210200529.GD3651@lukather>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Dec 11, 2013 at 4:05 AM, Maxime Ripard
<maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> wrote:
> Hi,
>
> On Mon, Dec 09, 2013 at 10:43:29AM +0800, Chen-Yu Tsai wrote:
>> >> @@ -2759,15 +2760,18 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>> >>               }
>> >>       }
>> >>
>> >> +     clk_disable_unprepare(priv->stmmac_clk);
>> >> +
>> >
>> > Hu? Why do you disable the clock? don't you need it afterwards?
>>
>> The clock is enabled in *_open (when the network interface is used),
>> and disabled in *_close.
>
> Maybe it is the real issue then.
>
> Why don't you move the clk_disable to _remove then?

I wasn't sure this was the proper way. However, looking around, it
seems other drivers enable the clock in, _probe, and disable it in
_remove. I will modify stmmac to do so as well.


ChenYu
