From: Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Subject: Re: [PATCH] net: davinci_emac: Replace devm_request_irq with
	request_irq
Date: Fri, 7 Mar 2014 03:28:00 +0100
Message-ID: <CABkLObo469sU=uznL-2Nb8aXYDV45wGNwCMVKdLvtb0Qywgnbw@mail.gmail.com>
References: <2ec3bb89-89db-48e8-b360-369545a2546f@mary.at.omicron.at>
	<20140306.165736.154818699714315258.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1524976174=="
Cc: "davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org"
	<davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        "f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org"
	<f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "jon-7zJyie9iPacdnm+yROfE0A@public.gmane.org" <jon-7zJyie9iPacdnm+yROfE0A@public.gmane.org>,
        "stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
	<stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <20140306.165736.154818699714315258.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============1524976174==
Content-Type: multipart/alternative; boundary="047d7bf0d498a9a48304f3fb003a"

--047d7bf0d498a9a48304f3fb003a
Content-Type: text/plain; charset="UTF-8"

On Thursday, March 6, 2014, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> From: Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org <javascript:;>>
> Date: Wed, 5 Mar 2014 11:25:28 +0100
>
> > @@ -1641,7 +1640,15 @@ static int emac_dev_open(struct net_device *ndev)
> >
> >  rollback:
> >
> > -     dev_err(emac_dev, "DaVinci EMAC: devm_request_irq() failed");
> > +     dev_err(emac_dev, "DaVinci EMAC: request_irq() failed");
> > +
> > +     for (q = k; k >= 0; k--) {
> > +             for (m = i; m >= res->start; m--)
> > +                     free_irq(m, ndev);
> > +             res = platform_get_resource(priv->pdev, IORESOURCE_IRQ,
> k-1);
> > +             m = res->end;
> > +     }
>
> This final assignment in the loop of 'm' is unused?
>
> The inner for() loop always started with "m = i;"
>
>
This should probably read

i = res->end;

I just took the old code, without thinking about it. Thanks for catching it.

Christian

--047d7bf0d498a9a48304f3fb003a
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<br><br>On Thursday, March 6, 2014, David Miller &lt;<a href=3D"mailto:dave=
m@davemloft.net">davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org</a>&gt; wrote:<br><blockquote class=3D=
"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding=
-left:1ex">
From: Christian Riesch &lt;<a href=3D"javascript:;" onclick=3D"_e(event, &#=
39;cvml&#39;, &#39;christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org&#39;)">christian.riesch@omic=
ron.at</a>&gt;<br>
Date: Wed, 5 Mar 2014 11:25:28 +0100<br>
<br>
&gt; @@ -1641,7 +1640,15 @@ static int emac_dev_open(struct net_device *nde=
v)<br>
&gt;<br>
&gt; =C2=A0rollback:<br>
&gt;<br>
&gt; - =C2=A0 =C2=A0 dev_err(emac_dev, &quot;DaVinci EMAC: devm_request_irq=
() failed&quot;);<br>
&gt; + =C2=A0 =C2=A0 dev_err(emac_dev, &quot;DaVinci EMAC: request_irq() fa=
iled&quot;);<br>
&gt; +<br>
&gt; + =C2=A0 =C2=A0 for (q =3D k; k &gt;=3D 0; k--) {<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (m =3D i; m &gt;=3D re=
s-&gt;start; m--)<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 free_irq(m, ndev);<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 res =3D platform_get_resou=
rce(priv-&gt;pdev, IORESOURCE_IRQ, k-1);<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 m =3D res-&gt;end;<br>
&gt; + =C2=A0 =C2=A0 }<br>
<br>
This final assignment in the loop of &#39;m&#39; is unused?<br>
<br>
The inner for() loop always started with &quot;m =3D i;&quot;<br><br>
</blockquote><div><br></div><div>This should probably read=C2=A0</div><div>=
<br></div><div>i =3D res-&gt;end;=C2=A0</div><div><br></div><div>I just too=
k the old code, without thinking about it. Thanks for catching it.</div><di=
v><br></div>
<div>Christian</div><div>=C2=A0</div>

--047d7bf0d498a9a48304f3fb003a--

--===============1524976174==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1524976174==--
