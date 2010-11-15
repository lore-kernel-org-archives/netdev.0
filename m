From: Stephen Hemminger <shemminger@vyatta.com>
Subject: network device reference leak with net-next
Date: Mon, 15 Nov 2010 10:56:46 -0800
Message-ID: <20101115105646.0cc823ce@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58312 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758162Ab0KOS4v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 13:56:51 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 97952182894E
	for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 10:56:50 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nr5basbsF1ba for <netdev@vger.kernel.org>;
	Mon, 15 Nov 2010 10:56:50 -0800 (PST)
Received: from nehalam (unknown [10.250.0.103])
	by mail.vyatta.com (Postfix) with ESMTPSA id 911D71828906
	for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 10:56:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a new regression (doesn't exist with 2.6.36)

If I shutdown KVM instance with Virt manager, the virtual
interfaces in the bridge aren't getting cleaned up because
of leftover reference count.


[ 9781.050474] unregister_netdevice: waiting for vnet1 to become free. Usage count = 1
[ 9785.143400] virbr4: port 3(vnet6) entering forwarding state
[ 9785.177194] virbr4: port 3(vnet6) entering disabled state
[ 9785.201129] device vnet6 left promiscuous mode
[ 9785.201135] virbr4: port 3(vnet6) entering disabled state
[ 9791.286950] unregister_netdevice: waiting for vnet1 to become free. Usage count = 1
[ 9795.461526] unregister_netdevice: waiting for vnet6 to become free. Usage count = 1
[ 9801.523398] unregister_netdevice: waiting for vnet1 to become free. Usage count = 1
