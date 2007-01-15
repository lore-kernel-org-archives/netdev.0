From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Tue, 16 Jan 2007 00:36:50 +0100
Message-ID: <45AC1012.2060705@cosmosbay.com>
References: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au> <45AB82F1.9000409@tls.msk.ru> <45ABC43F.7090202@cosmosbay.com> <45ABD710.5070105@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54208 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932118AbXAOXh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 18:37:26 -0500
To: Michael Tokarev <mjt@tls.msk.ru>
In-Reply-To: <45ABD710.5070105@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Tokarev a =E9crit :
> Eric Dumazet wrote:
>> Michael Tokarev a e'crit :
>>> Any idea how to force sending FIN-with-data?
>> int flag_on =3D 1;
>> setsockopt(fd, SOL_TCP, TCP_CORK, &flag_on, sizeof(int));
>> send(fd, data, datalen, 0);
>> close(fd);
>=20
> That produces two packets - one (or more - depending on the
> size) data packet and one FIN packet w/o any data.
>=20
> This is the first thing I've tried.

This may be because I forgot the shutdown() ?

int flag_on =3D 1;
setsockopt(fd, SOL_TCP, TCP_CORK, &flag_on, sizeof(int));
send(fd, data, datalen, 0);
shutdown(fd, 1);
close(fd);

At least this is working on my machines (with and without shutdown())

Eric
