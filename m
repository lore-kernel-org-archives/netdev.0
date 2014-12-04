From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/3] ip: Support checksum returned in csmg
Date: Wed,  3 Dec 2014 16:44:25 -0800
Message-ID: <1417653868-14922-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:40560 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbaLDAov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 19:44:51 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so13805629igb.11
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 16:44:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set allows the packet checksum for a datagram socket
to be returned in csum data in recvmsg. This allows userspace
to implement its own checksum over the data, for instance if an
IP tunnel was be implemented in user space, the inner checksum
could be validated.

Changes in this patch set:
  - Move checksum conversion to inet_sock from udp_sock. This
    generalizes checksum conversion for use with other protocols.
  - Move IP cmsg constants to a header file and make processing
    of the flags more efficient in ip_cmsg_recv.
  - Return checksum value in cmsg. This is specifically the unfolded
    32 bit checksum of the full packet starting from the first byte
    returned in recvmsg.

Tested: Wrote a little server to get checksums in cmsg for UDP and
        verfied correct checksum is returned.

Tom Herbert (3):
  ip: Move checksum convert defines to inet
  ip: IP cmsg cleanup
  ip: Add support for IP_CHECKSUM cmsg

 include/linux/udp.h     | 16 +--------
 include/net/inet_sock.h | 27 ++++++++++++++
 include/uapi/linux/in.h |  1 +
 net/ipv4/fou.c          |  2 +-
 net/ipv4/ip_sockglue.c  | 96 +++++++++++++++++++++++++++++++++++--------------
 net/ipv4/udp.c          | 12 +++++--
 net/ipv4/udp_tunnel.c   |  2 +-
 net/ipv6/udp.c          |  2 +-
 8 files changed, 111 insertions(+), 47 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
