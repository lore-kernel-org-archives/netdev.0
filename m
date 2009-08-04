From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Tue, 04 Aug 2009 09:38:19 +0200
Message-ID: <4A77E56B.9030804@gibraltar.at>
References: <4A65EC3F.4050400@gibraltar.at>	<20090723102848.00a56ad1@nehalam>	<4A6D8975.4050000@gibraltar.at> <20090727153548.7c0d9f85@nehalam> <4A76D036.6090705@gibraltar.at> <4A772A1D.1030904@mayrhofer.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	mikem@ring3k.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter.gibraltar.at ([80.120.3.98]:45927 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932646AbZHDHic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 03:38:32 -0400
In-Reply-To: <4A772A1D.1030904@mayrhofer.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Rene Mayrhofer wrote:
>> To allow easier debugging, I have now put our whole kernel tree up in a
>> public (read-only) git repository at
>> https://www.gibraltar.at/git/linux-2.6-gibraltar.git. The branch for
>> this kernel is origin/gibraltar-3.0, although the above dump was
>> produced by a version slightly "older" then HEAD, which did not yet have
>> the latest PaX patch applied (no PaX and no lzma-squashfs in this kernel).

> I have now updated the branch with both patches (the one from Stephen
> and the other one Mike). Still trying if it changes anything with
> 2.6.30.4 (they didn't help with 2.6.28.10, though...).

Result with both patches: there is no immediate crash when setting all
sky2 interfaces down, but I get the following messages repeated roughly
every second:

2009-08-04T09:35:31.030812+02:00 gibraltar3-esys-master kernel: [
592.000071] sky2 0000:01:00.0: device status error
2009-08-04T09:35:32.030908+02:00 gibraltar3-esys-master kernel: [
593.000058] sky2 0000:01:00.0: device status error
2009-08-04T09:35:33.030839+02:00 gibraltar3-esys-master kernel: [
594.000082] sky2 0000:01:00.0: device status error
2009-08-04T09:35:34.030864+02:00 gibraltar3-esys-master kernel: [
595.000118] sky2 0000:01:00.0: device status error
2009-08-04T09:35:35.030975+02:00 gibraltar3-esys-master kernel: [
596.000259] sky2 0000:01:00.0: device status error
2009-08-04T09:35:36.030974+02:00 gibraltar3-esys-master kernel: [
597.000198] sky2 0000:01:00.0: device status error
2009-08-04T09:35:37.030980+02:00 gibraltar3-esys-master kernel: [
598.000203] sky2 0000:01:00.0: device status error

and the network interface fails to work (no ping, nothing with tcpdump,
etc.).

Does anybody have an idea on what might be wrong in sky2_down?

best regards,
Rene
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkp35WsACgkQq7SPDcPCS97wHQCcCYWO2qgg+LdW+BFUmeOXjGVT
B68AniD3Ur2NugPGhuvz3Fxy68Zl+3f4
=5MhE
-----END PGP SIGNATURE-----
