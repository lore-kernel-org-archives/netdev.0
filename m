From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/4] dt-bindings: add binding for RTL8211E
 Ethernet PHY
Date: Fri, 21 Apr 2017 17:22:59 -0700
Message-ID: <c7aa9d7a-5e97-0e7f-2b1c-584a4de00837@gmail.com>
References: <20170421232436.10924-1-icenowy@aosc.io>
 <20170421232436.10924-3-icenowy@aosc.io>
Reply-To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
To: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
 Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-sunxi+bncBCH67JWTV4DBBZWE5LDQKGQE5HWURHY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170421232436.10924-3-icenowy-h8G6r0blFSE@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On 04/21/2017 04:24 PM, Icenowy Zheng wrote:
> From: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
> 
> Some RTL8211E Ethernet PHY have an issue that needs a workaround
> indicated with device tree.
> 
> Add the binding for a property that indicates this workaround.
> 
> Signed-off-by: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
> ---
>  .../devicetree/bindings/net/realtek,rtl8211e.txt   | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/realtek,rtl8211e.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/realtek,rtl8211e.txt b/Documentation/devicetree/bindings/net/realtek,rtl8211e.txt
> new file mode 100644
> index 000000000000..c1913301bfe8
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/realtek,rtl8211e.txt
> @@ -0,0 +1,22 @@
> +Realtek RTL8211E Ethernet PHY
> +
> +One batch of RTL8211E is slight broken, that needs some special (and
> +full of magic numbers) tweaking in order to make GbE to operate properly.
> +The only well-known board that used the broken batch is Pine64+.
> +Configure it through an Ethernet OF device node.
> +
> +Optional properties:
> +
> +- realtek,disable-rx-delay:
> +  If set, RX delay will be completely disabled (according to Realtek). This
> +  will affect the performance on non-broken boards.
> +  default: do not disable RX delay.

Please don't introduce custom properties to do that, instead correct
specify the "phy-mode" such that it is e.g: "rgmii-txid" which indicates
that there should be no RX internal delay, but a TX internal delay added
by the PHY.
-- 
Florian
