From: Daniel Lezcano <daniel.lezcano@linaro.org>
Subject: Re: [PATCH] net: dsa/slave: Fix compilation warnings
Date: Tue, 30 Oct 2012 10:00:20 +0100
Message-ID: <508F9724.50804@linaro.org>
References: <5afab1ebe83e4361f1fd75bbea0c559af195bf02.1351529738.git.viresh.kumar@linaro.org> <1351540778.2721.7.camel@bwh-desktop.uk.solarflarecom.com> <CAKohponL_3m2KVytiWm8ZHyB5aimk8CzGrqr5J0LMy8MFGodHg@mail.gmail.com> <CAKohponOKk5e2Sxyhjw-XvzVxF3tNp66rsnYCwvwHazAPAauKw@mail.gmail.com> <508F8779.8070300@linaro.org> <CAKohpokmfFSFsADmtOyN9JRCX8aVdNs+tDFhUQuM6sSQ+dFfUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	linaro-dev@lists.linaro.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, patches@linaro.org
To: Viresh Kumar <viresh.kumar@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKohpokmfFSFsADmtOyN9JRCX8aVdNs+tDFhUQuM6sSQ+dFfUA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/30/2012 08:55 AM, Viresh Kumar wrote:
> On 30 October 2012 13:23, Daniel Lezcano <daniel.lezcano@linaro.org> =
wrote:
>>> From: Viresh Kumar <viresh.kumar@linaro.org>
>=20
>>>  config NET_DSA_TAG_DSA
>>> -     bool
>>> +     bool "Original DSA packet tagging format"
>>> +     select NET_DSt
>>
>> typo NET_DSA
>=20
> Unbelievable mistake :(
>=20
> Will fix it after some reviews now :)

Yeah, has to be ! ;)

It is very curious if we disable all the configs option, a slave
creation raise a BUG (cf. dsa_slave_create). IIUC, booting with NET_DSA
enabled and none of the NET_DSA_TAG* enabled will raise a BUG in the
probe function, right ?

Maybe we should force at least one config when none are set ?

diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 274791c..86326e3 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -1,8 +1,9 @@
-config NET_DSA
+menuconfig NET_DSA
        tristate "Distributed Switch Architecture support"
        default n
        depends on EXPERIMENTAL && NETDEVICES && !S390
        select PHYLIB
+       select NET_DSA_TAG_DSA if (!NET_DSA_TAG_EDSA &&
!NET_DSA_TAG_TRAILER)
        ---help---
          This allows you to use hardware switch chips that use
          the Distributed Switch Architecture.
@@ -12,15 +13,15 @@ if NET_DSA

 # tagging formats
 config NET_DSA_TAG_DSA
-       bool
+       bool "tag dsa"
        default n

 config NET_DSA_TAG_EDSA
-       bool
+       bool "tag edsa"
        default n

 config NET_DSA_TAG_TRAILER
-       bool
+       bool "tag trailer"
        default n

 endif


--=20
 <http://www.linaro.org/> Linaro.org =E2=94=82 Open source software for=
 ARM SoCs

=46ollow Linaro:  <http://www.facebook.com/pages/Linaro> Facebook |
<http://twitter.com/#!/linaroorg> Twitter |
<http://www.linaro.org/linaro-blog/> Blog
