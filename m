From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net 0/3] ipv6: Return an error when adding an already existing tunnel
Date: Mon, 22 Sep 2014 10:07:23 +0200
Message-ID: <1411373246-22389-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53897 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753171AbaIVIHy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2014 04:07:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv6 tunnel locate functions should not return an existing
tunnel if create is true. Otherwise it is possible to add the
same tunnel multiple times without getting an error.

All our ipv6 tunnels have this bug from the very beginning.
Only the sit tunnel was fixed some years ago with:

commit 8db99e57175 ("sit: Fail to create tunnel, if it already exists").

This patchset fixes the remaining ipv6 tunnels.
