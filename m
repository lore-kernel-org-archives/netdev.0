From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: remove the unnecessary statement in find_match()
Date: Thu, 31 Oct 2013 14:02:11 +0800
Message-ID: <5271F263.4020800@cn.fujitsu.com>
References: <5270B7AE.9020801@cn.fujitsu.com> <20131030.170837.1882918923249091614.davem@davemloft.net> <20131030211157.GA13902@order.stressinduktion.org> <20131031.002234.45924350853188128.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:2535 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750845Ab3JaGEi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 02:04:38 -0400
In-Reply-To: <20131031.002234.45924350853188128.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B410=E6=9C=8831=E6=97=A5 12:22, David Miller =E5=86=
=99=E9=81=93:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 30 Oct 2013 22:11:57 +0100
>=20
>> On Wed, Oct 30, 2013 at 05:08:37PM -0400, David Miller wrote:
>>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>> Date: Wed, 30 Oct 2013 15:39:26 +0800
>>>
>>>>
>>>> After reading the function rt6_check_neigh(), we can
>>>> know that the RT6_NUD_FAIL_SOFT can be returned only
>>>> when the IS_ENABLE(CONFIG_IPV6_ROUTER_PREF) is false.
>>>> so in function find_match(), there is no need to execute
>>>> the statement !IS_ENABLED(CONFIG_IPV6_ROUTER_PREF).
>>>>
>>>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>>
>>> Applied to net-next, thanks.
>>>
>>> CONFIG_IPV6_ROUTER_PREF is another good candidate for Kconfig
>>> removal.  I know we've had several bugs that only apply when
>>> this option is on vs. off.  We're maintaining two different
>>> code paths, for really no good reason.
>>
>> I agree and actually thought about that yesterday. Do you think a sy=
sctl
>> is a good option?
>=20
> Every distribution ships with the Kconfig option on, and no sysctl
> exists currently to control it.
>=20
> So I'd say it's not necessary at all, or at the very least let's have
> someone come forward with a real rather than theoretical use case for
> such a feature before adding it.
>=20
> Actually, if RFC 4191 has the usual language like "there SHOULD be
> an administrative mechanism to disable blah blah blah" I could
> be convinced to add it now.  Can someone take a look?

It seems that there is no such an administrative mechanism in RFC 4191.

By the way, if the sysctl is used, we are still maintaining two differe=
nt
code paths, isn't it? so i think David's idea is good.

Thanks,
  Duan


>=20
> Either way it'd probably be a per-inet6_dev option, right?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
