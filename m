From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH 4/4 v2] net/smsc911x: Provide common clock functionality
Date: Thu, 27 Dec 2012 19:31:24 +0000
Message-ID: <CAF2Aj3jjTYRQ6sOHfQwZOtZ-HwLn2Rkt8oCZpT-TiS4gy7-Ojg@mail.gmail.com>
References: <1355937587-31730-1-git-send-email-lee.jones@linaro.org>
 <1355937587-31730-4-git-send-email-lee.jones@linaro.org>
 <CACRpkda79O_b3Z8g7Sy7vMtW9neZU4x-Z=iEQgjqu4X5tFKyhw@mail.gmail.com>
 <20121220192441.GC14363@n2100.arm.linux.org.uk>
 <20121220203514.GN2691@gmail.com>
 <20121220205113.GD14363@n2100.arm.linux.org.uk>
 <20121221091306.GO2691@gmail.com>
 <20121221092421.GG14363@n2100.arm.linux.org.uk>
 <20121221114105.GP2691@gmail.com>
 <CACRpkdZGC=f0X1wLt1QLMB=x+ba6VRDAbRcW6wR_2gvNLuGw1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5202514469534143445=="
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
 Robert Marklund <robert.marklund@stericsson.com>, linus.walleij@stericsson.com,
 arnd@arndb.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 linux-arm-kernel@lists.infradead.org
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CACRpkdZGC=f0X1wLt1QLMB=x+ba6VRDAbRcW6wR_2gvNLuGw1g@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

--===============5202514469534143445==
Content-Type: multipart/alternative; boundary=f46d043bdffab2bfe804d1da97cb

--f46d043bdffab2bfe804d1da97cb
Content-Type: text/plain; charset=ISO-8859-1

No, you're right, I'm a moron.

Will fix up and resend when I'm back to work.

Sent from my mobile Linux device.
On Dec 26, 2012 12:51 AM, "Linus Walleij" <linus.walleij@linaro.org> wrote:

> On Fri, Dec 21, 2012 at 12:41 PM, Lee Jones <lee.jones@linaro.org> wrote:
>
> > +       if (IS_ERR(pdata->clk)) {
> > +               ret = clk_prepare_enable(pdata->clk);
> > +               if (ret < 0)
> > +                       netdev_err(ndev, "failed to enable clock %d\n",
> ret);
> > +       }
>
> I think you got all of these backwards now, shouldn't it be if
> (!IS_ERR(pdata->clk)) { } ...?
>
> It's late here but enlighten me if I don't get it.
>
> > +       if (IS_ERR(pdata->clk))
> > +               clk_disable_unprepare(pdata->clk);
>
> Dito.
>
> > +       /* Request clock */
> > +       pdata->clk = clk_get(&pdev->dev, NULL);
> > +       if (IS_ERR(pdata->clk))
> > +               netdev_warn(ndev, "couldn't get clock %li\n",
> PTR_ERR(pdata->clk));
>
> This one seems correct though.
>
> > +       /* Free clock */
> > +       if (IS_ERR(pdata->clk)) {
> > +               clk_put(pdata->clk);
> > +               pdata->clk = NULL;
> > +       }
>
> Should be !IS_ERR()
>
> Yours,
> Linus Walleij
>

--f46d043bdffab2bfe804d1da97cb
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p>No, you&#39;re right, I&#39;m a moron.</p>
<p>Will fix up and resend when I&#39;m back to work.</p>
<p>Sent from my mobile Linux device.</p>
<div class=3D"gmail_quote">On Dec 26, 2012 12:51 AM, &quot;Linus Walleij&qu=
ot; &lt;<a href=3D"mailto:linus.walleij@linaro.org">linus.walleij@linaro.or=
g</a>&gt; wrote:<br type=3D"attribution"><blockquote class=3D"gmail_quote" =
style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
On Fri, Dec 21, 2012 at 12:41 PM, Lee Jones &lt;<a href=3D"mailto:lee.jones=
@linaro.org">lee.jones@linaro.org</a>&gt; wrote:<br>
<br>
&gt; + =A0 =A0 =A0 if (IS_ERR(pdata-&gt;clk)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D clk_prepare_enable(pdata-&gt;clk=
);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret &lt; 0)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(ndev, &quot;f=
ailed to enable clock %d\n&quot;, ret);<br>
&gt; + =A0 =A0 =A0 }<br>
<br>
I think you got all of these backwards now, shouldn&#39;t it be if<br>
(!IS_ERR(pdata-&gt;clk)) { } ...?<br>
<br>
It&#39;s late here but enlighten me if I don&#39;t get it.<br>
<br>
&gt; + =A0 =A0 =A0 if (IS_ERR(pdata-&gt;clk))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clk_disable_unprepare(pdata-&gt;clk);<br=
>
<br>
Dito.<br>
<br>
&gt; + =A0 =A0 =A0 /* Request clock */<br>
&gt; + =A0 =A0 =A0 pdata-&gt;clk =3D clk_get(&amp;pdev-&gt;dev, NULL);<br>
&gt; + =A0 =A0 =A0 if (IS_ERR(pdata-&gt;clk))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_warn(ndev, &quot;couldn&#39;t get=
 clock %li\n&quot;, PTR_ERR(pdata-&gt;clk));<br>
<br>
This one seems correct though.<br>
<br>
&gt; + =A0 =A0 =A0 /* Free clock */<br>
&gt; + =A0 =A0 =A0 if (IS_ERR(pdata-&gt;clk)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clk_put(pdata-&gt;clk);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdata-&gt;clk =3D NULL;<br>
&gt; + =A0 =A0 =A0 }<br>
<br>
Should be !IS_ERR()<br>
<br>
Yours,<br>
Linus Walleij<br>
</blockquote></div>

--f46d043bdffab2bfe804d1da97cb--


--===============5202514469534143445==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============5202514469534143445==--
