From: Stig Venaas <Stig.Venaas@uninett.no>
Subject: Problem with recvmsg() and IPV6_PKTINFO
Date: Fri, 11 Feb 2005 10:21:07 +0100
Message-ID: <20050211092107.GB12377@storhaugen.uninett.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

By setting IPV6_PKTINFO (or IPV6_RECVPKTINFO) on a socket one should
be able to use recvmsg() to receive a datagram and get the destination
address as ancillary data.

I've found that on Linux (checked 2.4, 2.6 and USAGI cvs) this only
happens if msg_name in the msghdr structure is set. In kernel's
udpv6_recvmsg() you can see that datagram_recv_ctl() is only called if
msg->msg_name is set.

I don't think one should need to set msg_name for this to work. The
specs (RFC 3542 and the Single UNIX Specification) talks about
msg_name being optional, it never says that msg_name is needed for
this to work.

This problem is when receiving UDP on a regular socket, that is:

socket(PF_INET6, SOCK_DGRAM, IPPROTO_UDP)

It works without setting msg_name for IPv4 and also raw sockets.

I also checked on FreeBSD. You don't need to set msg_name there
either.

Stig
