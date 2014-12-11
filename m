From: Phillip Susi <psusi@ubuntu.com>
Subject: bind() should not return -EADDRINUSE
Date: Thu, 11 Dec 2014 14:19:11 -0500
Message-ID: <5489EE2F.6030502@ubuntu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:62458 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757802AbaLKTTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 14:19:15 -0500
Received: by mail-qa0-f50.google.com with SMTP id w8so3995850qac.23
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 11:19:15 -0800 (PST)
Received: from [10.1.1.214] (fl-67-77-88-12.sta.embarqhsd.net. [67.77.88.12])
        by mx.google.com with ESMTPSA id n4sm1875151qge.2.2014.12.11.11.19.14
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Dec 2014 11:19:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Attempting to establish a connection to a remote host using the same
local port, but a different remote port as the previous connection (
that is still in TIME_WAIT ) results in bind() returning -EADDRINUSE.
 By changing the remote port, you avoid the conflict with the other
connection that is in TIME_WAIT, but since the remote port is not
known when bind() is called, it incorrectly returns -EADDRINUSE.  This
check should not be done in bind(), but deferred until the remote port
is known in the call to connect(), or listen().

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)

iQEcBAEBAgAGBQJUie4vAAoJENRVrw2cjl5R8CgH/jgdrBXs1Yso7XsHtrsUgO75
P8bY3Mf8eOuAkLvwbHopyGr19UZJJ+5zCQWc6bus9BRa7jSQvPCRw8fSjg3u+NXs
r9/qEqiDrYwAJqV5SwqDPGU8xGwq8v31bbT09spGIL9fABW3krBFtDHcZ/PzGA/p
UGDgELdkU7QIMKvC7FAV5RzvMXpmAI+m7iQiF936QkGZPN0AOCTea0sB+IpeidTO
/ChLd2iaEqAmS6UGh3jIQSNcTB3Ho3imHHMjTCel2v8+SgCBb2Tp3HzfmmIsGAnh
YeH+ZCNHD08c+k9yprEVjCH6fwMOo7CWzyPnSme+Ggk0L5r9oj8iz4xIeIMv43o=
=Ou3S
-----END PGP SIGNATURE-----
