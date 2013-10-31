From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 0/2] cdc_mbim workarounds for firmware bugs
Date: Thu, 31 Oct 2013 15:56:09 +0100
Message-ID: <1383231371-8098-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gsuarez@smithmicro.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34820 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754738Ab3JaPB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Oct 2013 11:01:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first patch is an attempt to work around a bug which prevents
some devices from working with IPv6. I guess handling ND in a driver
can be considered controversial, but it was the best alternative I
came up with.

The second is the "final solution" to the well known ZLP bug, which
as we feared is present in a number of devices using different
vendor IDs. Enabling this is definitely controversial, but I do not
see any other possible solution.  The blacklist has become
unmanagable, and I am pretty sure it is very incomplete due to
under-reporting.  Devices known to work without ZLPs can be added
to the whitelist.

Bj=C3=B8rn Mork (2):
  net: cdc_mbim: handle IPv6 Neigbor Solicitations
  net: cdc_mbim: change the default to send ZLPs

 drivers/net/usb/cdc_mbim.c |   86 ++++++++++++++++++++++++++++++++++++=
++------
 1 file changed, 75 insertions(+), 11 deletions(-)

--=20
1.7.10.4
