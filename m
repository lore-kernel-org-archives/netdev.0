From: Phillip Susi <psusi@ubuntu.com>
Subject: Re: bind() should not return -EADDRINUSE
Date: Thu, 11 Dec 2014 14:50:48 -0500
Message-ID: <5489F598.9020708@ubuntu.com>
References: <5489EE2F.6030502@ubuntu.com> <20141211.142355.854082841833367081.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:45614 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbaLKTux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 14:50:53 -0500
Received: by mail-qc0-f169.google.com with SMTP id w7so4483929qcr.14
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 11:50:51 -0800 (PST)
In-Reply-To: <20141211.142355.854082841833367081.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 12/11/2014 2:23 PM, David Miller wrote:
> From: Phillip Susi <psusi@ubuntu.com> Date: Thu, 11 Dec 2014
> 14:19:11 -0500
> 
>> Attempting to establish a connection to a remote host using the
>> same local port, but a different remote port as the previous
>> connection ( that is still in TIME_WAIT ) results in bind()
>> returning -EADDRINUSE. By changing the remote port, you avoid the
>> conflict with the other connection that is in TIME_WAIT, but
>> since the remote port is not known when bind() is called, it
>> incorrectly returns -EADDRINUSE.  This check should not be done
>> in bind(), but deferred until the remote port is known in the
>> call to connect(), or listen().
> 
> Bind has to allocate and hold from everyone else on the system the 
> local port at bind() time, so we cannot defer this decision.

What on earth for?  If two processes are going to connect to different
remotes using the same source, that is perfectly fine.  The only
contention is if two processes want to listen() with the same local
addr and wildcard remote.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)

iQEcBAEBAgAGBQJUifWYAAoJENRVrw2cjl5RpckH/2g9V0p3SFNvf1qmR1nxZjJ6
R19eosdoWvCL6B2pIqwvpy64ACqTf6MS3NrdZt6TwSz+8OKqBj/D8+IpKcAdo5kU
Yzhl3qASkm17HTeOmGhw00pqJkD4FYzzwb8hw/OxwxWUwpVLvv+nMYHhF7vwgOy6
h90Kmj6ycOeY/+sX5Woe5RheKq+AlDqJGAELk1Vs9lrRDDa/3o/HqEQX5HNsohyC
ib2dJRAdCuNN9KjSKuVLnCu4Tf1UB5W+efSK21qN/s1r0a0RWXMe2ph6JrYQsg2e
H2nl7Ifiv/4VbuvRkabSsrge8bJtw76c2uMpxw1GHNUN1rNnxhGAj4J1oOIp4rQ=
=LXdQ
-----END PGP SIGNATURE-----
