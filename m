From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH 0/2 net-next] sunvnet: fix null pointer deref and crash recovery
Date: Mon, 26 Jan 2015 15:54:14 -0500
Message-ID: <54C6A976.4060502@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43987 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958AbbAZUyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 15:54:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix an incorrect ordering in releasing ring data, clear pending
tx buffers on a reset, and make the sunvnet driver more reliable when remote
systems crash during active transmits.

David L Stevens (2):
  sunvnet: free pending tx buffers before clearing ring data
  sunvnet: improve error handling when a remote crashes

 drivers/net/ethernet/sun/sunvnet.c |   83 +++++++++++++++++++----------------
 1 files changed, 45 insertions(+), 38 deletions(-)
