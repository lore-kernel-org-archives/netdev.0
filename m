From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: release referenct of ip6_null_entry's dst entry
 in __ip6_del_rt
Date: Mon, 24 Sep 2012 12:32:14 +0800
Message-ID: <505FE24E.4030204@cn.fujitsu.com>
References: <1348118734-2967-1-git-send-email-gaofeng@cn.fujitsu.com> <20120921.131652.353726055575103840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:48273 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751379Ab2IXEcL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 00:32:11 -0400
In-Reply-To: <20120921.131652.353726055575103840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B409=E6=9C=8822=E6=97=A5 01:16, David Miller =E5=86=
=99=E9=81=93:
> From: Gao feng <gaofeng@cn.fujitsu.com>
> Date: Thu, 20 Sep 2012 13:25:34 +0800
>=20
>> as we hold dst_entry before we call __ip6_del_rt,
>> so we should alse call dst_release not only return
>> -ENOENT when the rt6_info is ip6_null_entry.
>>
>> and we already hold the dst entry, so I think it's
>> safe to call dst_release out of the write-read lock.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>=20
> I cannot find a code path where we can actually end up
> with an ip6_null_entry here and I'd much rather declare
> this condition as a bug.
>=20
> Patrick McHardy added this check back in 2006:
>=20
> 	commit 6c813a7297e3af4cd7c3458e09e9ee3d161c6830
> 	Author: Patrick McHardy <kaber@trash.net>
> 	Date:   Sun Aug 6 22:22:47 2006 -0700
>=20
> 	    [IPV6]: Fix crash in ip6_del_rt
>=20
> But the ipv6 code has changed substantially since then.

ip -6 route del ::/0 will end up with an ip6_null_entry.
so I think this checking and this patch is needed .
