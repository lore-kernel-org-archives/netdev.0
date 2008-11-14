From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: make sure struct dst_entry refcount is aligned on
 64 bytes
Date: Fri, 14 Nov 2008 14:37:38 +0100
Message-ID: <491D7F22.9020707@cosmosbay.com>
References: <491D323B.9030802@cosmosbay.com> <20081114.005437.09284570.davem@davemloft.net> <491D3F18.5030505@cosmosbay.com> <20081114093613.GA2834@x200.localdomain> <491D5725.50006@cosmosbay.com> <20081114113558.GA9692@x200.localdomain> <491D644A.4040309@cosmosbay.com> <20081114132230.GA27462@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:33627 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbYKNNhu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 08:37:50 -0500
In-Reply-To: <20081114132230.GA27462@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan a =E9crit :

> Hmm, indeed.
>=20
> I tried moving __refcnt et al to the very beginning, but it seems to =
make
> things worse (on x86_64, almost within statistical error).
>=20
> And there is no way to use offset_of() inside struct definition. :-(

Yes, it is important that the beginning of structure contain read mostl=
y fields.

refcnt being the most written field (incremented / decremented for each=
 packet),
it is really important to move it outside of the first 128 bytes=20
(192 bytes on 64 bit arches) of dst_entry

I wonder if some real hot dst_entries could be splitted (one copy for e=
ach stream),
to reduce ping-pongs.

