From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v4] ethernet/arc/arc_emac - Add new driver
Date: Sun, 16 Jun 2013 00:41:31 -0700
Message-ID: <1371368491.2116.0.camel@joe-AO722>
References: <1371327652-9368-1-git-send-email-abrodkin@synopsys.com>
 <1371328671.2117.6.camel@joe-AO722>
 <4881796E12491D4BB15146FE0209CE643F5E7779@DE02WEMBXB.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
 <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
 "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Vineet Gupta <Vineet.Gupta1-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
 "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>,
 Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>, Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 Mischa Jonker <Mischa.Jonker-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
To: Alexey Brodkin <Alexey.Brodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <4881796E12491D4BB15146FE0209CE643F5E7779-okAzG6w2b9vBRDCkatnZjvufCSb+aD3WLzEdoUbNIic@public.gmane.org>
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

On Sat, 2013-06-15 at 20:47 +0000, Alexey Brodkin wrote:
> On 06/16/2013 12:37 AM, Joe Perches wrote:
> > On Sun, 2013-06-16 at 00:20 +0400, Alexey Brodkin wrote:
[]
> >> +static int arc_emac_rx(struct net_device *ndev, int budget)
> > []
> >> +		/* Prepare the BD for next cycle */
> >> +		rx_buff->skb = netdev_alloc_skb_ip_align(ndev, buflen);
> >> +		if (unlikely(!rx_buff->skb)) {
> >> +			if (net_ratelimit())
> >> +				netdev_err(ndev, "cannot allocate skb\n");
> >
> > Unnecessary OOM message, might as well remove it.
> > rx_dropped gives the same info.
> 
> With all those error messages I wanted to make life easier (especially 
> for me) if errors appear. User will immediately know where problem 
> happened. Indeed "rx_dropped" (when it is used only once in driver) may 
> show where issue happened, but if later at some point "rx_dropped" will 
> be incremented in other locations then user won't understand immediately 
> where error happened.

Alloc errors emit a dump_stack() already so this is redundant.
