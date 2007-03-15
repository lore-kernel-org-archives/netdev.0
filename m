From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [patch 1/4] network dev read_mostly
Date: Thu, 15 Mar 2007 07:28:35 +0100
Message-ID: <45F8E793.7040603@cosmosbay.com>
References: <20070312210817.485320783@linux-foundation.org> <20070312210907.509184287@linux-foundation.org> <20070315021840.GG1246@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58562 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422823AbXCOG2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2007 02:28:48 -0400
In-Reply-To: <20070315021840.GG1246@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin LaHaise a =E9crit :
> On Mon, Mar 12, 2007 at 02:08:18PM -0700, Stephen Hemminger wrote:
>> For Eric, mark packet type and network device watermarks
>> as read mostly.
>=20
> The following x86-64 bits might be intersting, as they allow you to=20
> completely eliminate the memory access for run time defined constants=
=2E =20
> Note that read_always writes are non-atomic, so some other form of=20
> protection is necessary for readers (and rcu won't cut it).  That can=
 be=20
> fixed somewhat by specifying the alignment for the mov instruction to=
=20
> ensure writes are atomic, but for many uses that is overkill.  This k=
ind=20
> of change can make the biggest difference for high-latency cases, lik=
e L1=20
> cache misses on the Prescott P4.  I've not benched it on a P4 of late=
,=20
> though.
>=20

Very very nice idea Ben !

However netdev_nit is not a good condidate because it might change quit=
e often=20
in fact :(

Clearly kmem_cache pointers are very good candidates.

One problem with your patch is that all read_always() of pointers are g=
oing to=20
use 3 bytes more of code, thus raising icache pressure.

48 b8 c3 08 e8 8c af    mov    $0x71af8ce808c3,%rax
71 00 00

instead of %rip relative addressing

48 8b 05 99 f3 09 00    mov    652185(%rip),%rax


