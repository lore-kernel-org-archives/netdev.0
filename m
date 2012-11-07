From: Viresh Kumar <viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] net: dsa/slave: Fix compilation warnings
Date: Wed, 7 Nov 2012 09:20:08 +0530
Message-ID: <CAKohpo=c=hESJvU6CyuzNvf6-bvxi55Z3xDJU-9T1Wo3h0D2Rw@mail.gmail.com>
References: <5afab1ebe83e4361f1fd75bbea0c559af195bf02.1351529738.git.viresh.kumar@linaro.org>
	<1351540778.2721.7.camel@bwh-desktop.uk.solarflarecom.com>
	<CAKohponL_3m2KVytiWm8ZHyB5aimk8CzGrqr5J0LMy8MFGodHg@mail.gmail.com>
	<CAKohponOKk5e2Sxyhjw-XvzVxF3tNp66rsnYCwvwHazAPAauKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8638832677728977987=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linaro-dev-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linaro-dev-bounces-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>
In-Reply-To: <CAKohponOKk5e2Sxyhjw-XvzVxF3tNp66rsnYCwvwHazAPAauKw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://lists.linaro.org/mailman/options/linaro-dev>,
	<mailto:linaro-dev-request-cunTk1MwBs8s++Sfvej+rw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linaro.org/pipermail/linaro-dev>
List-Post: <mailto:linaro-dev-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>
List-Help: <mailto:linaro-dev-request-cunTk1MwBs8s++Sfvej+rw@public.gmane.org?subject=help>
List-Subscribe: <http://lists.linaro.org/mailman/listinfo/linaro-dev>,
	<mailto:linaro-dev-request-cunTk1MwBs8s++Sfvej+rw@public.gmane.org?subject=subscribe>
Sender: linaro-dev-bounces-cunTk1MwBs8s++Sfvej+rw@public.gmane.org
Errors-To: linaro-dev-bounces-cunTk1MwBs8s++Sfvej+rw@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============8638832677728977987==
Content-Type: multipart/alternative; boundary=14dae9340ddf62369804cddf9db2

--14dae9340ddf62369804cddf9db2
Content-Type: text/plain; charset=ISO-8859-1

On 30 October 2012 13:01, Viresh Kumar <viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:


> From: Viresh Kumar <viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> Date: Mon, 29 Oct 2012 22:19:14 +0530
> Subject: [PATCH] net: dsa/slave: Fix compilation warnings
>

Ping!!


>
> Currently when none of CONFIG_NET_DSA_TAG_DSA, CONFIG_NET_DSA_TAG_EDSA and
> CONFIG_NET_DSA_TAG_TRAILER is defined, we get following compilation
> warnings:
>
> net/dsa/slave.c:51:12: warning: 'dsa_slave_init' defined but not used
> [-Wunused-function]
> net/dsa/slave.c:60:12: warning: 'dsa_slave_open' defined but not used
> [-Wunused-function]
> net/dsa/slave.c:98:12: warning: 'dsa_slave_close' defined but not used
> [-Wunused-function]
> net/dsa/slave.c:116:13: warning: 'dsa_slave_change_rx_flags' defined
> but not used [-Wunused-function]
> net/dsa/slave.c:127:13: warning: 'dsa_slave_set_rx_mode' defined but
> not used [-Wunused-function]
> net/dsa/slave.c:136:12: warning: 'dsa_slave_set_mac_address' defined
> but not used [-Wunused-function]
> net/dsa/slave.c:164:12: warning: 'dsa_slave_ioctl' defined but not
> used [-Wunused-function]
>
> Earlier approach to fix this was discussed here:
>
> lkml.org/lkml/2012/10/29/549
>
> This is another approach to fix it. This is done by some changes in config
> options, which make more sense than the earlier approach. As, atleast one
> tagging option must always be selected for using net/dsa/ infrastructure,
> this
> patch selects NET_DSA from tagging configs instead of having it as an
> selectable
> config.
>
> Signed-off-by: Viresh Kumar <viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>  drivers/net/dsa/Kconfig |  1 -
>  net/dsa/Kconfig         | 16 +++++++++-------
>  2 files changed, 9 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
> index dd151d5..96eae22 100644
> --- a/drivers/net/dsa/Kconfig
> +++ b/drivers/net/dsa/Kconfig
> @@ -1,5 +1,4 @@
>  menu "Distributed Switch Architecture drivers"
> -       depends on NET_DSA
>
>  config NET_DSA_MV88E6XXX
>         tristate
> diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
> index 274791c..f7c6cef 100644
> --- a/net/dsa/Kconfig
> +++ b/net/dsa/Kconfig
> @@ -1,5 +1,5 @@
>  config NET_DSA
> -       tristate "Distributed Switch Architecture support"
> +       tristate
>         default n
>         depends on EXPERIMENTAL && NETDEVICES && !S390
>         select PHYLIB
> @@ -8,19 +8,21 @@ config NET_DSA
>           the Distributed Switch Architecture.
>
>
> -if NET_DSA
> +menu "Distributed Switch Architecture support"
>
>  # tagging formats
>  config NET_DSA_TAG_DSA
> -       bool
> +       bool "Original DSA packet tagging format"
> +       select NET_DSt
>         default n
>
>  config NET_DSA_TAG_EDSA
> -       bool
> +       bool "Ethertype DSA packet tagging format"
> +       select NET_DSA
>         default n
>
>  config NET_DSA_TAG_TRAILER
> -       bool
> +       bool "Trailer DSA packet tagging format"
> +       select NET_DSA
>         default n
> -
> -endif
> +endmenu
>

--14dae9340ddf62369804cddf9db2
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 30 October 2012 13:01, Viresh Kumar <span dir=3D"ltr">&lt;<a href=3D"mai=
lto:viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" target=3D"_blank">viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org</a>&=
gt;</span> wrote:<br><div class=3D"gmail_quote"><div>=A0</div><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex">
<div class=3D"im">From: Viresh Kumar &lt;<a href=3D"mailto:viresh.kumar@lin=
aro.org">viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org</a>&gt;</div>
Date: Mon, 29 Oct 2012 22:19:14 +0530<br>
Subject: [PATCH] net: dsa/slave: Fix compilation warnings<br></blockquote><=
div><br></div><div>Ping!!</div><div>=A0</div><blockquote class=3D"gmail_quo=
te" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"=
>

<div class=3D"im"><br>
Currently when none of CONFIG_NET_DSA_TAG_DSA, CONFIG_NET_DSA_TAG_EDSA and<=
br>
CONFIG_NET_DSA_TAG_TRAILER is defined, we get following compilation warning=
s:<br>
<br>
net/dsa/slave.c:51:12: warning: &#39;dsa_slave_init&#39; defined but not us=
ed<br>
[-Wunused-function]<br>
net/dsa/slave.c:60:12: warning: &#39;dsa_slave_open&#39; defined but not us=
ed<br>
[-Wunused-function]<br>
net/dsa/slave.c:98:12: warning: &#39;dsa_slave_close&#39; defined but not u=
sed<br>
[-Wunused-function]<br>
net/dsa/slave.c:116:13: warning: &#39;dsa_slave_change_rx_flags&#39; define=
d<br>
but not used [-Wunused-function]<br>
net/dsa/slave.c:127:13: warning: &#39;dsa_slave_set_rx_mode&#39; defined bu=
t<br>
not used [-Wunused-function]<br>
net/dsa/slave.c:136:12: warning: &#39;dsa_slave_set_mac_address&#39; define=
d<br>
but not used [-Wunused-function]<br>
net/dsa/slave.c:164:12: warning: &#39;dsa_slave_ioctl&#39; defined but not<=
br>
used [-Wunused-function]<br>
<br>
</div>Earlier approach to fix this was discussed here:<br>
<br>
<a href=3D"http://lkml.org/lkml/2012/10/29/549" target=3D"_blank">lkml.org/=
lkml/2012/10/29/549</a><br>
<br>
This is another approach to fix it. This is done by some changes in config<=
br>
options, which make more sense than the earlier approach. As, atleast one<b=
r>
tagging option must always be selected for using net/dsa/ infrastructure, t=
his<br>
patch selects NET_DSA from tagging configs instead of having it as an selec=
table<br>
config.<br>
<div class=3D"im"><br>
Signed-off-by: Viresh Kumar &lt;<a href=3D"mailto:viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org">=
viresh.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org</a>&gt;<br>
---<br>
</div>=A0drivers/net/dsa/Kconfig | =A01 -<br>
=A0net/dsa/Kconfig =A0 =A0 =A0 =A0 | 16 +++++++++-------<br>
=A02 files changed, 9 insertions(+), 8 deletions(-)<br>
<br>
diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig<br>
index dd151d5..96eae22 100644<br>
--- a/drivers/net/dsa/Kconfig<br>
+++ b/drivers/net/dsa/Kconfig<br>
@@ -1,5 +1,4 @@<br>
=A0menu &quot;Distributed Switch Architecture drivers&quot;<br>
- =A0 =A0 =A0 depends on NET_DSA<br>
<br>
=A0config NET_DSA_MV88E6XXX<br>
=A0 =A0 =A0 =A0 tristate<br>
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig<br>
index 274791c..f7c6cef 100644<br>
--- a/net/dsa/Kconfig<br>
+++ b/net/dsa/Kconfig<br>
@@ -1,5 +1,5 @@<br>
=A0config NET_DSA<br>
- =A0 =A0 =A0 tristate &quot;Distributed Switch Architecture support&quot;<=
br>
+ =A0 =A0 =A0 tristate<br>
=A0 =A0 =A0 =A0 default n<br>
=A0 =A0 =A0 =A0 depends on EXPERIMENTAL &amp;&amp; NETDEVICES &amp;&amp; !S=
390<br>
=A0 =A0 =A0 =A0 select PHYLIB<br>
@@ -8,19 +8,21 @@ config NET_DSA<br>
=A0 =A0 =A0 =A0 =A0 the Distributed Switch Architecture.<br>
<br>
<br>
-if NET_DSA<br>
+menu &quot;Distributed Switch Architecture support&quot;<br>
<br>
=A0# tagging formats<br>
=A0config NET_DSA_TAG_DSA<br>
- =A0 =A0 =A0 bool<br>
+ =A0 =A0 =A0 bool &quot;Original DSA packet tagging format&quot;<br>
+ =A0 =A0 =A0 select NET_DSt<br>
=A0 =A0 =A0 =A0 default n<br>
<br>
=A0config NET_DSA_TAG_EDSA<br>
- =A0 =A0 =A0 bool<br>
+ =A0 =A0 =A0 bool &quot;Ethertype DSA packet tagging format&quot;<br>
+ =A0 =A0 =A0 select NET_DSA<br>
=A0 =A0 =A0 =A0 default n<br>
<br>
=A0config NET_DSA_TAG_TRAILER<br>
- =A0 =A0 =A0 bool<br>
+ =A0 =A0 =A0 bool &quot;Trailer DSA packet tagging format&quot;<br>
+ =A0 =A0 =A0 select NET_DSA<br>
=A0 =A0 =A0 =A0 default n<br>
-<br>
-endif<br>
+endmenu<br>
</blockquote></div><br>

--14dae9340ddf62369804cddf9db2--


--===============8638832677728977987==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linaro-dev mailing list
linaro-dev-cunTk1MwBs8s++Sfvej+rw@public.gmane.org
http://lists.linaro.org/mailman/listinfo/linaro-dev

--===============8638832677728977987==--
