From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Fix for the fundamental network/block layer race in sendfile().
Date: Tue, 01 Apr 2008 22:59:18 +0200
Message-ID: <47F2A226.60708@cosmosbay.com>
References: <20080328092036.GA11924@2ka.mipt.ru> <20080328.134053.122172549.davem@davemloft.net> <20080328205613.GA24812@2ka.mipt.ru> <20080328.140736.92315090.davem@davemloft.net> <20080328215131.GB24812@2ka.mipt.ru> <20080401164904.GA2382@2ka.mipt.ru> <47F26EAB.7040900@cosmosbay.com> <20080401174759.GB28217@2ka.mipt.ru> <20080401180751.GA3263@2ka.mipt.ru> <47F28B2F.2070609@cosmosbay.com> <20080401194527.GA26833@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, axboe@kernel.dk,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604006av.neufgp.fr ([84.96.92.121]:54336
	"EHLO neuf-infra-smtp-out-sp604006av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760329AbYDAU7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 16:59:46 -0400
In-Reply-To: <20080401194527.GA26833@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov a =E9crit :
> On Tue, Apr 01, 2008 at 09:21:19PM +0200, Eric Dumazet (dada1@cosmosb=
ay.com) wrote:
>> I see no socket locking, so multiple threads could use sendfile() &=20
>> sendmsg() on same socket, and crash kernel...
>=20
> How?
> Those who use sendfile() automatically install page->lru.prev which i=
s
> checked in release path, only those with given value will be processe=
d
> as spliced (i.e. new callback).
>=20
> It is safe to install new callback on skbs which were not spliced, si=
nce
> for that skbs it will be pure sock_wfree().
>=20

first thread is doing its sendfile, and clears the bit while second thr=
ead

just entered sendfile() too, just after setting the bit and calling

do_splice_direct()

skb_set_owner_w() see the bit cleared, so install normal sock_wfree des=
tructor=20
instead of sh_user_data.

crash or leak god_bless_us, you chose :)

