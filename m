From: "Jari Takkala" <Jari.Takkala@Q9.com>
Subject: RE: [PATCH 2.6.23.12] net/bonding: option to specify initial bond interface number
Date: Thu, 3 Jan 2008 10:23:08 -0500
Message-ID: <413FEEF1743111439393FB76D0221E4809790A30@leopard.zoo.q9networks.com>
References: <22042.1199312663@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: "Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.q9.com ([216.220.35.252]:60621 "EHLO mx3.q9.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042AbYACPXK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 10:23:10 -0500
Content-class: urn:content-classes:message
In-Reply-To: <22042.1199312663@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, January 02, 2008 17:24, Jay Vosburgh wrote:
> 	What advantage does this have over:
> 
> # echo +bond5 > /sys/class/net/bonding_masters
> 
> 	which will create a new bonding master for the already-loaded driver?
>

The advantage is that you can load multiple instances of the bonding driver and control the name of the bond interface that will be created. Normally the bond interface name would take the next available number.

In our startup scripts we need to be able to ensure that the interface name is consistent across reboots. Sometimes bond1 may be brought up before bond0 and it may have different options (requiring a different instance of the bonding driver).

I understand that the startup scripts could be modified to account for this, however we also have an IOS like interface to an embedded system where the user can create new bond interfaces and specify the interface number, they may create interfaces out of order and this feature enables them to accomplish that.

Jari
