From: SathyaNarayanan <sathyan@teamf1.com>
Subject: Re: [PATCH] ibm_newemac: Fixes kernel crashes when speed of cable
	connected changes
Date: Fri, 27 Jun 2008 12:24:59 +0530
Message-ID: <1946a170806262354k582ad86asc9a1a8383aad45a4@mail.gmail.com>
References: <1214225694-25815-1-git-send-email-sr@denx.de>
	<1214263216.8011.276.camel@pasglop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1276537554=="
Cc: linuxppc-dev@ozlabs.org, Stefan Roese <sr@denx.de>, netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1214263216.8011.276.camel@pasglop>
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

--===============1276537554==
Content-Type: multipart/alternative;
	boundary="----=_Part_10107_9885088.1214549699185"

------=_Part_10107_9885088.1214549699185
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi benh,

               Please find my comments inline.

Thanks and regards,
SathyaNarayanan

On Tue, Jun 24, 2008 at 4:50 AM, Benjamin Herrenschmidt <
benh@kernel.crashing.org> wrote:

> On Mon, 2008-06-23 at 14:54 +0200, Stefan Roese wrote:
> > From: Sathya Narayanan <sathyan@teamf1.com>
> >
> > The descriptor pointers were not initialized to NIL values, so it was
> > poiniting to some random addresses which was completely invalid. This
> > fix takes care of initializing the descriptor to NIL values and clearing
> > the valid descriptors on clean ring operation.
> >
> > Signed-off-by: Sathya Narayanan <sathyan@teamf1.com>
> > Signed-off-by: Stefan Roese <sr@denx.de>
> > ---
> >  drivers/net/ibm_newemac/core.c |    6 +++++-
> >  1 files changed, 5 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/net/ibm_newemac/core.c
> b/drivers/net/ibm_newemac/core.c
> > index 5d2108c..6dfc2c9 100644
> > --- a/drivers/net/ibm_newemac/core.c
> > +++ b/drivers/net/ibm_newemac/core.c
> > @@ -1025,7 +1025,7 @@ static void emac_clean_tx_ring(struct emac_instance
> *dev)
> >       int i;
> >
> >       for (i = 0; i < NUM_TX_BUFF; ++i) {
> > -             if (dev->tx_skb[i]) {
> > +             if (dev->tx_skb[i] && dev->tx_desc[i].data_ptr) {
>
> Why changing the test above ?


   The reason for changing this condition is ,  In any of the case if the
dev->tx_skb is not containing valid address, Then while clearing it you may
be resulted in "address voilations". This additional condition ensures that
we are clearing the valid skbs.
Further this condition is not in general data flow, So this additional
condition should not have any impact on performance.

>
>
> >                       dev_kfree_skb(dev->tx_skb[i]);
> >                       dev->tx_skb[i] = NULL;
> >                       if (dev->tx_desc[i].ctrl & MAL_TX_CTRL_READY)
> > @@ -2719,6 +2719,10 @@ static int __devinit emac_probe(struct of_device
> *ofdev,
> >       /* Clean rings */
> >       memset(dev->tx_desc, 0, NUM_TX_BUFF * sizeof(struct
> mal_descriptor));
> >       memset(dev->rx_desc, 0, NUM_RX_BUFF * sizeof(struct
> mal_descriptor));
> > +     for (i = 0; i <= NUM_TX_BUFF; i++)
> > +             dev->tx_skb[i] = NULL;
> > +     for (i = 0; i <= NUM_RX_BUFF; i++)
> > +             dev->rx_skb[i] = NULL;
>
> Why not use memset here too ?

    Yes, It was valid to use memset here. I can send the modified patch for
it.

>
>
> >       /* Attach to ZMII, if needed */
> >       if (emac_has_feature(dev, EMAC_FTR_HAS_ZMII) &&
>
>

------=_Part_10107_9885088.1214549699185
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi benh,<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Please find my comments inline.<br><br>Thanks and regards,<br>SathyaNarayanan<br><br><div class="gmail_quote">On Tue, Jun 24, 2008 at 4:50 AM, Benjamin Herrenschmidt &lt;<a href="mailto:benh@kernel.crashing.org" target="_blank">benh@kernel.crashing.org</a>&gt; wrote:<br>

<blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;"><div>On Mon, 2008-06-23 at 14:54 +0200, Stefan Roese wrote:<br>
&gt; From: Sathya Narayanan &lt;<a href="mailto:sathyan@teamf1.com" target="_blank">sathyan@teamf1.com</a>&gt;<br>
&gt;<br>
&gt; The descriptor pointers were not initialized to NIL values, so it was<br>
&gt; poiniting to some random addresses which was completely invalid. This<br>
&gt; fix takes care of initializing the descriptor to NIL values and clearing<br>
&gt; the valid descriptors on clean ring operation.<br>
&gt;<br>
&gt; Signed-off-by: Sathya Narayanan &lt;<a href="mailto:sathyan@teamf1.com" target="_blank">sathyan@teamf1.com</a>&gt;<br>
&gt; Signed-off-by: Stefan Roese &lt;<a href="mailto:sr@denx.de" target="_blank">sr@denx.de</a>&gt;<br>
&gt; ---<br>
&gt; &nbsp;drivers/net/ibm_newemac/core.c | &nbsp; &nbsp;6 +++++-<br>
&gt; &nbsp;1 files changed, 5 insertions(+), 1 deletions(-)<br>
&gt;<br>
&gt; diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c<br>
&gt; index 5d2108c..6dfc2c9 100644<br>
&gt; --- a/drivers/net/ibm_newemac/core.c<br>
&gt; +++ b/drivers/net/ibm_newemac/core.c<br>
&gt; @@ -1025,7 +1025,7 @@ static void emac_clean_tx_ring(struct emac_instance *dev)<br>
&gt; &nbsp; &nbsp; &nbsp; int i;<br>
&gt;<br>
&gt; &nbsp; &nbsp; &nbsp; for (i = 0; i &lt; NUM_TX_BUFF; ++i) {<br>
&gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (dev-&gt;tx_skb[i]) {<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (dev-&gt;tx_skb[i] &amp;&amp; dev-&gt;tx_desc[i].data_ptr) {<br>
<br>
</div>Why changing the test above ?</blockquote><div><br>&nbsp;&nbsp; The reason for changing this condition is ,&nbsp; In any of the case if the dev-&gt;tx_skb is not containing valid address, Then while clearing it you may be resulted in &quot;address voilations&quot;. This additional condition ensures that we are clearing the valid skbs.<br>

Further this condition is not in general data flow, So this additional condition should not have any impact on performance.<br></div><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">

<br>
<div><br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev_kfree_skb(dev-&gt;tx_skb[i]);<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev-&gt;tx_skb[i] = NULL;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (dev-&gt;tx_desc[i].ctrl &amp; MAL_TX_CTRL_READY)<br>
&gt; @@ -2719,6 +2719,10 @@ static int __devinit emac_probe(struct of_device *ofdev,<br>
&gt; &nbsp; &nbsp; &nbsp; /* Clean rings */<br>
&gt; &nbsp; &nbsp; &nbsp; memset(dev-&gt;tx_desc, 0, NUM_TX_BUFF * sizeof(struct mal_descriptor));<br>
&gt; &nbsp; &nbsp; &nbsp; memset(dev-&gt;rx_desc, 0, NUM_RX_BUFF * sizeof(struct mal_descriptor));<br>
&gt; + &nbsp; &nbsp; for (i = 0; i &lt;= NUM_TX_BUFF; i++)<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev-&gt;tx_skb[i] = NULL;<br>
&gt; + &nbsp; &nbsp; for (i = 0; i &lt;= NUM_RX_BUFF; i++)<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev-&gt;rx_skb[i] = NULL;<br>
<br>
</div>Why not use memset here too ?</blockquote><div>&nbsp; &nbsp; Yes, It was valid to use memset here. I can send the modified patch for it. <br></div><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">

<br>
<div><div></div><div><br>
&gt; &nbsp; &nbsp; &nbsp; /* Attach to ZMII, if needed */<br>
&gt; &nbsp; &nbsp; &nbsp; if (emac_has_feature(dev, EMAC_FTR_HAS_ZMII) &amp;&amp;<br>
<br>
</div></div></blockquote></div><br>

------=_Part_10107_9885088.1214549699185--

--===============1276537554==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============1276537554==--
