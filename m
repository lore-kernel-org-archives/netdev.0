From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH] net: sk_prot_alloc() should not blindly overwrite memory
Date: Wed, 8 Jul 2009 17:35:51 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365F8AD4E371@rrsmsx501.amr.corp.intel.com>
References: <4A53CD39.7080407@gmail.com>
	<20090707.191424.167842005.davem@davemloft.net>
	<EA929A9653AAE14F841771FB1DE5A1365F8ACEC9A1@rrsmsx501.amr.corp.intel.com>
 <20090708.104539.226485646.davem@davemloft.net> <4A552A0D.8080106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "emils.tantilov@gmail.com" <emils.tantilov@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"jolsa@redhat.com" <jolsa@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:37139 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754661AbZGHXgD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 19:36:03 -0400
In-Reply-To: <4A552A0D.8080106@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> David Miller a =E9crit :
>> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
>> Date: Wed, 8 Jul 2009 11:02:22 -0600
>>=20
>>> Still seeing traces during the test even with this patch applied:
>>>=20
>>> [ 1089.430093] ------------[ cut here ]------------
>>> [ 1089.435667] WARNING: at include/net/sock.h:423
>>> udp_lib_unhash+0x73/0xa0() [ 1089.435670] Hardware name: S5520HC
>>=20
>> Ok I'll back this out for now, needs more investigation
>> obviously.
>=20
> Hmm... I never said it was supposed to fix Emil problem, just that
> I discovered one potential problem by code inspection.
>=20
> I could not find yet sk_refcnt mismatch.
> As we do less atomic ops per packet than before, some old bug could
> surface now...
>=20
> Emil, is it easy to reproduce this problem, considering I have a
> similar platform than yours (dual quad core machine, E5450 cpus @
> 3GHz) ?=20

Eric,

It should be easy to reproduce. At least I have been able to consistent=
ly=20
reproduce it on several different systems with different drivers (e1000=
, e1000e, igb).=20

The test I'm running is a mix of IPV4/6 TCP/UDP traffic with netperf (a=
lso mixing different types TCP/UDP_STREAM, TCP_MAERTS, TCP_UDP_RR etc).=
 How much this matters I don't know - it's possible that just UDP traff=
ic would do it. I also think it may have something to do with IPv6
because of the trace, but I am not sure.

If you need more information let me know.

Thanks,
Emil