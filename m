From: Daniel Lezcano <daniel.lezcano@linaro.org>
Subject: Re: [PATCH] net: dsa/slave: Fix compilation warnings
Date: Tue, 30 Oct 2012 08:53:29 +0100
Message-ID: <508F8779.8070300@linaro.org>
References: <5afab1ebe83e4361f1fd75bbea0c559af195bf02.1351529738.git.viresh.kumar@linaro.org> <1351540778.2721.7.camel@bwh-desktop.uk.solarflarecom.com> <CAKohponL_3m2KVytiWm8ZHyB5aimk8CzGrqr5J0LMy8MFGodHg@mail.gmail.com> <CAKohponOKk5e2Sxyhjw-XvzVxF3tNp66rsnYCwvwHazAPAauKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	linaro-dev@lists.linaro.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, patches@linaro.org
To: Viresh Kumar <viresh.kumar@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKohponOKk5e2Sxyhjw-XvzVxF3tNp66rsnYCwvwHazAPAauKw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/30/2012 08:31 AM, Viresh Kumar wrote:
> On 30 October 2012 12:15, Viresh Kumar <viresh.kumar@linaro.org> wrot=
e:
>> And so, if we select NET_DSA from these tagging drivers, then only s=
lave.c will
>> get compiled. Otherwise slave.c dsa.c dsa_core.c wouldn't be compile=
d and so
>> no warnings.
>=20
> If my above explanation/assumption is correct, then please review fol=
lowing
> patch:
>=20
> --------------------------x-----------------------x----------------
>=20
> From: Viresh Kumar <viresh.kumar@linaro.org>
> Date: Mon, 29 Oct 2012 22:19:14 +0530
> Subject: [PATCH] net: dsa/slave: Fix compilation warnings
>=20
> Currently when none of CONFIG_NET_DSA_TAG_DSA, CONFIG_NET_DSA_TAG_EDS=
A and
> CONFIG_NET_DSA_TAG_TRAILER is defined, we get following compilation w=
arnings:
>=20
> net/dsa/slave.c:51:12: warning: 'dsa_slave_init' defined but not used
> [-Wunused-function]
> net/dsa/slave.c:60:12: warning: 'dsa_slave_open' defined but not used
> [-Wunused-function]
> net/dsa/slave.c:98:12: warning: 'dsa_slave_close' defined but not use=
d
> [-Wunused-function]
> net/dsa/slave.c:116:13: warning: 'dsa_slave_change_rx_flags' defined
> but not used [-Wunused-function]
> net/dsa/slave.c:127:13: warning: 'dsa_slave_set_rx_mode' defined but
> not used [-Wunused-function]
> net/dsa/slave.c:136:12: warning: 'dsa_slave_set_mac_address' defined
> but not used [-Wunused-function]
> net/dsa/slave.c:164:12: warning: 'dsa_slave_ioctl' defined but not
> used [-Wunused-function]
>=20
> Earlier approach to fix this was discussed here:
>=20
> lkml.org/lkml/2012/10/29/549
>=20
> This is another approach to fix it. This is done by some changes in c=
onfig
> options, which make more sense than the earlier approach. As, atleast=
 one
> tagging option must always be selected for using net/dsa/ infrastruct=
ure, this
> patch selects NET_DSA from tagging configs instead of having it as an=
 selectable
> config.
>=20
> Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
> ---
>  drivers/net/dsa/Kconfig |  1 -
>  net/dsa/Kconfig         | 16 +++++++++-------
>  2 files changed, 9 insertions(+), 8 deletions(-)
>=20
> diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
> index dd151d5..96eae22 100644
> --- a/drivers/net/dsa/Kconfig
> +++ b/drivers/net/dsa/Kconfig
> @@ -1,5 +1,4 @@
>  menu "Distributed Switch Architecture drivers"
> -	depends on NET_DSA
>=20
>  config NET_DSA_MV88E6XXX
>  	tristate
> diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
> index 274791c..f7c6cef 100644
> --- a/net/dsa/Kconfig
> +++ b/net/dsa/Kconfig
> @@ -1,5 +1,5 @@
>  config NET_DSA
> -	tristate "Distributed Switch Architecture support"
> +	tristate
>  	default n
>  	depends on EXPERIMENTAL && NETDEVICES && !S390
>  	select PHYLIB
> @@ -8,19 +8,21 @@ config NET_DSA
>  	  the Distributed Switch Architecture.
>=20
>=20
> -if NET_DSA
> +menu "Distributed Switch Architecture support"
>=20
>  # tagging formats
>  config NET_DSA_TAG_DSA
> -	bool
> +	bool "Original DSA packet tagging format"
> +	select NET_DSt

typo NET_DSA

>  	default n
>=20
>  config NET_DSA_TAG_EDSA
> -	bool
> +	bool "Ethertype DSA packet tagging format"
> +	select NET_DSA
>  	default n
>=20
>  config NET_DSA_TAG_TRAILER
> -	bool
> +	bool "Trailer DSA packet tagging format"
> +	select NET_DSA
>  	default n
> -
> -endif
> +endmenu
>=20
> _______________________________________________
> linaro-dev mailing list
> linaro-dev@lists.linaro.org
> http://lists.linaro.org/mailman/listinfo/linaro-dev


--=20
 <http://www.linaro.org/> Linaro.org =E2=94=82 Open source software for=
 ARM SoCs

=46ollow Linaro:  <http://www.facebook.com/pages/Linaro> Facebook |
<http://twitter.com/#!/linaroorg> Twitter |
<http://www.linaro.org/linaro-blog/> Blog
