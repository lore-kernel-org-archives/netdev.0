From: SathyaNarayanan <sathyan@teamf1.com>
Subject: Re: [PATCH] ibm_newemac: Fixes entry of short packets
Date: Fri, 27 Jun 2008 12:06:06 +0530
Message-ID: <1946a170806262336y4aa3621at16520fc546bbe4b1@mail.gmail.com>
References: <1214225705-25850-1-git-send-email-sr@denx.de>
	<1214263257.8011.278.camel@pasglop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1132971297=="
Cc: linuxppc-dev@ozlabs.org, Stefan Roese <sr@denx.de>, netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1214263257.8011.278.camel@pasglop>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--===============1132971297==
Content-Type: multipart/alternative;
	boundary="----=_Part_10092_4396745.1214548566483"

------=_Part_10092_4396745.1214548566483
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi benh,

            Please find my comments inline.

On Tue, Jun 24, 2008 at 4:50 AM, Benjamin Herrenschmidt <
benh@kernel.crashing.org> wrote:

> On Mon, 2008-06-23 at 14:55 +0200, Stefan Roese wrote:
> > From: Sathya Narayanan <sathyan@teamf1.com>
> >
> > Short packets has to be discarded by the driver. So this patch addresses
> the
> > issue of discarding the short packets of size lesser then ethernet header
> > size.
>
> You are freeing the skb, why ? Shouldn't we just keep the skb in the
> ring for further rx ?


Actually , short packets are not allowed to flow through the higher layers,
If any of the layer tried to use the extra room available may hit wit crash
.
Since it is a invalid packet it has to be dropped and freed in driver.
Actually if you see in code, the other invalid packets are also handelled
similar.


>
> > Signed-off-by: Sathya Narayanan <sathyan@teamf1.com>
> > Signed-off-by: Stefan Roese <sr@denx.de>
> > ---
> >  drivers/net/ibm_newemac/core.c |    7 +++++++
> >  1 files changed, 7 insertions(+), 0 deletions(-)
> >
> > diff --git a/drivers/net/ibm_newemac/core.c
> b/drivers/net/ibm_newemac/core.c
> > index 6dfc2c9..aa407b2 100644
> > --- a/drivers/net/ibm_newemac/core.c
> > +++ b/drivers/net/ibm_newemac/core.c
> > @@ -1652,6 +1652,13 @@ static int emac_poll_rx(void *param, int budget)
> >
> >               skb_put(skb, len);
> >       push_packet:
> > +             if (skb->len < ETH_HLEN) {
> > +                     dev_kfree_skb(skb);
> > +                     printk(KERN_WARNING "%s: short packets dropped\n",
> > +                            dev->ndev->name);
> > +                     ++dev->estats.rx_dropped_stack;
> > +                     goto next;
> > +             }
> >               skb->dev = dev->ndev;
> >               skb->protocol = eth_type_trans(skb, dev->ndev);
> >               emac_rx_csum(dev, skb, ctrl);
>
>

------=_Part_10092_4396745.1214548566483
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi benh,<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Please find my comments inline.<br><br><div class="gmail_quote">On Tue, Jun 24, 2008 at 4:50 AM, Benjamin Herrenschmidt &lt;<a href="mailto:benh@kernel.crashing.org">benh@kernel.crashing.org</a>&gt; wrote:<br>
<blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;"><div class="Ih2E3d">On Mon, 2008-06-23 at 14:55 +0200, Stefan Roese wrote:<br>
&gt; From: Sathya Narayanan &lt;<a href="mailto:sathyan@teamf1.com">sathyan@teamf1.com</a>&gt;<br>
&gt;<br>
&gt; Short packets has to be discarded by the driver. So this patch addresses the<br>
&gt; issue of discarding the short packets of size lesser then ethernet header<br>
&gt; size.<br>
<br>
</div>You are freeing the skb, why ? Shouldn&#39;t we just keep the skb in the<br>
ring for further rx ?</blockquote><div><br>Actually , short packets are not allowed to flow through the higher layers, If any of the layer tried to use the extra room available may hit wit crash .<br>Since it is a invalid packet it has to be dropped and freed in driver.<br>
Actually if you see in code, the other invalid packets are also handelled similar.<br><br></div><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
<br>
<div><div></div><div class="Wj3C7c"><br>
&gt; Signed-off-by: Sathya Narayanan &lt;<a href="mailto:sathyan@teamf1.com">sathyan@teamf1.com</a>&gt;<br>
&gt; Signed-off-by: Stefan Roese &lt;<a href="mailto:sr@denx.de">sr@denx.de</a>&gt;<br>
&gt; ---<br>
&gt; &nbsp;drivers/net/ibm_newemac/core.c | &nbsp; &nbsp;7 +++++++<br>
&gt; &nbsp;1 files changed, 7 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c<br>
&gt; index 6dfc2c9..aa407b2 100644<br>
&gt; --- a/drivers/net/ibm_newemac/core.c<br>
&gt; +++ b/drivers/net/ibm_newemac/core.c<br>
&gt; @@ -1652,6 +1652,13 @@ static int emac_poll_rx(void *param, int budget)<br>
&gt;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; skb_put(skb, len);<br>
&gt; &nbsp; &nbsp; &nbsp; push_packet:<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (skb-&gt;len &lt; ETH_HLEN) {<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev_kfree_skb(skb);<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; printk(KERN_WARNING &quot;%s: short packets dropped\n&quot;,<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;dev-&gt;ndev-&gt;name);<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ++dev-&gt;estats.rx_dropped_stack;<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; goto next;<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; }<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; skb-&gt;dev = dev-&gt;ndev;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; skb-&gt;protocol = eth_type_trans(skb, dev-&gt;ndev);<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; emac_rx_csum(dev, skb, ctrl);<br>
<br>
</div></div></blockquote></div><br>

------=_Part_10092_4396745.1214548566483--

--===============1132971297==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============1132971297==--
