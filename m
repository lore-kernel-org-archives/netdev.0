From: Chris J Arges <chris.j.arges@canonical.com>
Subject: iproute2: potential upgrade regression with 58a3e827
Date: Fri, 08 Nov 2013 12:03:20 -0600
Message-ID: <527D2768.1030403@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:39427 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757765Ab3KHSDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 13:03:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
The commit
https://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/commit/?id=58a3e8270fe72f8ed92687d3a3132c2a708582dd
could be potentially introducing a regression on an upgrade.

I've noticed that upgrading iproute while there are active namespaces
could cause the following error:
seting the network namespace failed: Invalid argument

Here's a test case:
Build and install iproute2 with 4395d48c78a77a99c5a8618403211032356fe552

In one terminal run:
ip netns add netns_old
ip link add name if_old type veth peer name if_old_peer
ip link set dev if_old_peer netns netns_old
ip netns exec netns_old bash

Build and install iproute2 with 58a3e8270fe72f8ed92687d3a3132c2a708582dd

In the same terminal as you typed the original commands run:
ip netns add netns_one
ip link add name if_one type veth peer name if_one_peer
ip link set dev if_one_peer netns netns_one
ip netns exec netns_one bash
ip netns exec netns_old bash

You'll get:
seting the network namespace failed: Invalid argument

If you just run the above without transitioning to the code in 58a3e827,
then it works.

Thanks,
--chris j arges
