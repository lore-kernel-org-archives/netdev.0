From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next v3 0/4] ip: Support checksum returned in csmg
Date: Mon,  5 Jan 2015 13:56:13 -0800
Message-ID: <1420494977-15026-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:43722 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441AbbAEV4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 16:56:25 -0500
Received: by mail-ig0-f181.google.com with SMTP id a13so43283igq.14
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 13:56:25 -0800 (PST)
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
    of the flags more efficient in ip_cmsg_recv
  - Return checksum value in cmsg. This is specifically the unfolded
    32 bit checksum of the full packet starting from the first byte
    returned in recvmsg

Tested: Wrote a little server to get checksums in cmsg for UDP and
        verfied correct checksum is returned.
        
Tom Herbert (4):
  ip: Move checksum convert defines to inet
  ip: IP cmsg cleanup
  ip: Add offset parameter to ip_cmsg_recv
  ip: Add offset parameter to ip_cmsg_recv

 include/linux/udp.h     |  16 +------
 include/net/inet_sock.h |  29 ++++++++++++-
 include/net/ip.h        |   7 +++-
 include/uapi/linux/in.h |   1 +
 net/ipv4/fou.c          |   2 +-
 net/ipv4/ip_sockglue.c  | 108 +++++++++++++++++++++++++++++++++++-------------
 net/ipv4/udp.c          |   4 +-
 net/ipv4/udp_tunnel.c   |   2 +-
 net/ipv6/udp.c          |   2 +-
 9 files changed, 120 insertions(+), 51 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
