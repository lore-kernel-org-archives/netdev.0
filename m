From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH V2] ipv6: fix incorrect route 'expires' value passed to
 userspace
Date: Fri, 20 Jul 2012 09:32:18 +0800
Message-ID: <5008B522.4030005@cn.fujitsu.com>
References: <5003CC41.9080204@cn.fujitsu.com> <20120716.025649.1070277404591664104.davem@davemloft.net> <50076AD3.1060604@cn.fujitsu.com> <20120719.104906.38765587582698093.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54742 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752087Ab2GTBdO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 21:33:14 -0400
In-Reply-To: <20120719.104906.38765587582698093.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012-7-20 1:49, David Miller =E5=86=99=E9=81=93:
> From: Li Wei <lw@cn.fujitsu.com>
> Date: Thu, 19 Jul 2012 10:02:59 +0800
>=20
>>
>> When userspace use RTM_GETROUTE to dump route table, with an already
>> expired route entry, we always got an 'expires' value(2147157)
>> calculated base on INT_MAX.
>>
>> The reason of this problem is in the following satement:
>> 	rt->dst.expires - jiffies < INT_MAX
>> gcc promoted the type of both sides of '<' to unsigned long, thus
>> a small negative value would be considered greater than INT_MAX.
>>
>> This patch fix this by use the same trick as time_after macro to
>> avoid the 'unsigned long' type promotion and deal with jiffies
>> wrapping.
>>
>> Also we should do some fix in rtnl_put_cacheinfo() which use
>> jiffies_to_clock_t(which take an unsigned long as parameter) to
>> convert jiffies to clock_t to handle the negative expires.
>>
>> Signed-off-by: Li Wei <lw@cn.fujitsu.com>
>=20
> Your patch is corrupted by your email client and therefore will
> not apply cleanly.
>=20
> I think this isn't the first time your patch submissions have
> had this problem, and if so then you should do the necessary
> work to prevent problem with more certainty in the future as
> such this makes a lot of extra work for other people.
>=20

Really sorry for that, I'll resend this patch and before that sending
myself a copy to confirm the mail client works properly.

Thanks
