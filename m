From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC, PATCH] dont insert sockets/pipes dentries into
 dentry_hashtable.
Date: Wed, 01 Nov 2006 10:04:20 +0100
Message-ID: <45486314.3020300@cosmosbay.com>
References: <20061025084726.GE18364@nuim.ie>
 <20061025.230615.92585270.davem@davemloft.net>
 <200610311948.48970.dada1@cosmosbay.com>
 <20061031.231954.23010447.davem@davemloft.net>
 <454858F2.5020206@cosmosbay.com> <20061101083811.GS29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604002mt.neufgp.fr ([84.96.92.61]:18566 "EHLO sMtp.neuf.fr")
	by vger.kernel.org with ESMTP id S1423959AbWKAJEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 04:04:20 -0500
In-reply-to: <20061101083811.GS29920@ftp.linux.org.uk>
To: Al Viro <viro@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro a =E9crit :
> On Wed, Nov 01, 2006 at 09:21:06AM +0100, Eric Dumazet wrote:
>=20
>> And " (deleted)" is correctly added to deleted files.
>=20
> The hell it will.
>=20
> touch a
> touch b
> exec 5<a
> mv b a
> ls -l /proc/$$/fd/5
>=20
> With your patch and without it, please.

Yes I will do, thanks.

>=20
> PS: getting rid of socket dentries is a bad idea with the capital "Fu=
ck, No".
> For those who want to see where does that path lead and are attracted=
 to
> trainwrecks in general I can recommend *BSD socket handling.  They ha=
ve
> paid quite painfully for lack of proper vnodes.  It's simply not wort=
h
> the resulting trouble.

I have one server with one million sockets, wasting 210 MB of ram for d=
entries=20
that are only used when some guy does some /proc/$pid/fd work

Socket hot path already dont use anymore dentries, thanks to file->priv=
ate_data

Eric

