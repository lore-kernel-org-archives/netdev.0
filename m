From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: non-symmetric Unix dgram sockets and poll
Date: Wed, 2 Feb 2011 17:36:40 +0000
Message-ID: <20110202173640.2af412f0@chocolatine.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:44637 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756Ab1BBRi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 12:38:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have 3 Unix dgram sockets (sockA, sockB, sockC):
- sockA is connected to sockB.
- sockB is connected to sockC.
- sockC is not connected.

SockA cannot send any message to sockB because net/unix/af_unix.c::unix_may_send()
prevents it. Is there any reason for that restriction?

If it was possible to send that message, unix_dgram_poll() on sockB could be in a
situation where it needs to add the current process in 2 different wait queues:
- sk_sleep(sk) for POLLIN (messages coming from sockA)
- &unix_sk(other)->peer_wait for POLLOUT (to send messages to sockC)

Is it correct?

Thanks,
Alban
