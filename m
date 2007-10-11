From: Steven Dake <sdake@redhat.com>
Subject: bytes received from recvmsg doesn't match FIONREAD
Date: Thu, 11 Oct 2007 16:08:15 -0700
Message-ID: <1192144096.4147.16.camel@balance>
Reply-To: sdake@redhat.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59730 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752385AbXJKXIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 19:08:07 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id l9BN87P1022369
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 19:08:07 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l9BN87P5019478
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 19:08:07 -0400
Received: from [10.14.51.25] (vpn-51-25.sfbay.redhat.com [10.14.51.25])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l9BN85bK003739
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 19:08:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I wanted to verify that the size of a multicast UDP message received
with recvmsg matches the size of the message the kernel thinks the
message is.

So I went about using the FIONREAD ioctl as follows:

res = ioctl (fd, FIONCREAD, &value);
assert (res != -1);
bytes_received = recvmsg (fd, &msg_recv, MSG_NOSIGNAL | MSG_DONTWAIT);
assert (bytes_received == value);

It appears the value and bytes_received do not match after many
thousands of runs with a UDP multicast protocol (www.openais.org).
(neither is -1)

Am I using this ioctl improperly?  Shouldn't I expect that the full
datagram is returned by recvmsg no matter the state of the blocking or
nonblocking mode of the file descriptor?

pls copy me on responses - i am not onlist.

Regards
-steve

