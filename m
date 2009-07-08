From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sk_prot_alloc() should not blindly overwrite memory
Date: Thu, 09 Jul 2009 01:21:49 +0200
Message-ID: <4A552A0D.8080106@gmail.com>
References: <4A53CD39.7080407@gmail.com>	<20090707.191424.167842005.davem@davemloft.net>	<EA929A9653AAE14F841771FB1DE5A1365F8ACEC9A1@rrsmsx501.amr.corp.intel.com> <20090708.104539.226485646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: emil.s.tantilov@intel.com, emils.tantilov@gmail.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, jolsa@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52297 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755770AbZGHXWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 19:22:16 -0400
In-Reply-To: <20090708.104539.226485646.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> Date: Wed, 8 Jul 2009 11:02:22 -0600
>=20
>> Still seeing traces during the test even with this patch applied:
>>
>> [ 1089.430093] ------------[ cut here ]------------
>> [ 1089.435667] WARNING: at include/net/sock.h:423 udp_lib_unhash+0x7=
3/0xa0()
>> [ 1089.435670] Hardware name: S5520HC
>=20
> Ok I'll back this out for now, needs more investigation
> obviously.

Hmm... I never said it was supposed to fix Emil problem, just that=20
I discovered one potential problem by code inspection.

I could not find yet sk_refcnt mismatch.
As we do less atomic ops per packet than before, some old bug could sur=
face
now...

Emil, is it easy to reproduce this problem, considering I have a simila=
r
platform than yours (dual quad core machine, E5450 cpus @ 3GHz) ?

