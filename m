From: "David Shwatrz" <dshwatrz@gmail.com>
Subject: [PATCH net-2.6][NEIGH] Updating affected neighbours when about MAC address change
Date: Sun, 23 Dec 2007 13:41:36 +0200
Message-ID: <31436f4a0712230341x5a0abf08q7e6f7917ba7e38f0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:18876 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbXLWLlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 06:41:36 -0500
Received: by wa-out-1112.google.com with SMTP id v27so1896859wah.23
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2007 03:41:36 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Attached here is the patch - please read the following text here below:

 We know that changes in MAC addresses are not frequent but
we are working on a special, highly advanced networking Linux based project
in our LABs, where we do change MAC addresses of an interface quite frequently.
(We do not go totally wild; the MAC addresses we are changing into are
from a set of given MAC addresses).

Normally, when we change a MAC address of some interface, the
relevant neighbours in the LAN which have entries with the previous MAC
address are not sent any update notification; instead, it is there
regular timers mechanisms which update the MAC address to the new
one in their ARP tables.

I had written a small patch to neigh_changeaddr() in net/core/neighbour.c
against the 2.6 git net tree, which sends a gratuitous ARP to update
the list of
all the involved neighbours with the change of MAC address.
The patch is for neigh_changeaddr() only.

This patch was tested and it does work in my LAB; if such a patch is
not needed,
I wonder why ?
It seems to me that it could not cause any troubles.
BTW, I had noticed that in irlan driver, there is such a mechanism
of sending a gratuitous ARP to update all the
neighbours when a MAC address is changed.

Signed-off-by: David Shwatrz <dshwatrz@gmail.com>
