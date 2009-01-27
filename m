From: Patrick McHardy <kaber@trash.net>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Tue, 27 Jan 2009 12:37:18 +0100
Message-ID: <497EF1EE.7000304@trash.net>
References: <497E361B.30909@hp.com> <497E42F4.7080201@cosmosbay.com> <497E44F6.2010703@hp.com> <497ECF84.1030308@cosmosbay.com> <497ED0A2.6050707@trash.net> <497EF030.10504@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35463 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbZA0LhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 06:37:25 -0500
In-Reply-To: <497EF030.10504@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>  =20
>> Thats an interesting test-case, but one lock per conntrack just for
>> TCP tracking seems like overkill. We're trying to keep the conntrack
>> stuctures as small as possible, so I'd prefer an array of spinlocks
>> or something like that.
>>    =20
>
> Yes, this is wise. Current sizeof(struct nf_conn) is 220 (0xdc) on 32=
 bits,
> probably rounded to 0xE0 by SLAB/SLUB. I will provide a new patch usi=
ng
> an array of say 512 spinlocks. (512 spinlocks use 2048 bytes if non
> debuging spinlocks, that spread to 32 x 64bytes cache lines)
>  =20

Sounds good, but it should be limited to NR_CPUS I guess.
> However I wonder if for very large number of cpus we should at least =
ask conntrack=20
> to use hardware aligned "struct nf_conn" to avoid false sharing
>  =20

I'm not sure that is really a problem in practice, you usually have qui=
te a
few inactive conntrack entries and false sharing would only happen when=
 two
consequitive entries are active.


