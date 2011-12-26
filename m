From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bna: Added flash sub-module and ethtool eeprom
 entry points.
Date: Mon, 26 Dec 2011 10:10:35 -0500 (EST)
Message-ID: <20111226.101035.782817982749726680.davem@davemloft.net>
References: <B5EE62D80D50B84BB9E5174F7FCCE80A206BE39A24@HQ1-EXCH02.corp.brocade.com>
	<1324721314.3860.11.camel@deadeye>
	<4EF86253.3010108@computer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, kgudipat@Brocade.com,
	netdev@vger.kernel.org, adapter_linux_open_src_team@Brocade.com,
	rmody@Brocade.com
To: jan.ceuleers@computer.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38131 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752705Ab1LZPLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 10:11:47 -0500
In-Reply-To: <4EF86253.3010108@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Ceuleers <jan.ceuleers@computer.org>
Date: Mon, 26 Dec 2011 13:02:27 +0100

> Is it OK to hold the RTNL lock for that length of time?

No, because it means that no network configuration of any kind can
occur during this time.

Backbone routers need to perform hundreds of routing table updates per
second, even more during major route flaps.  All of these would be
blocked during your flash operation.
