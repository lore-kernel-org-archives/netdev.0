From: Chuck Lever <chuck.lever@oracle.com>
Subject: [RFC] [PATCH 0/2] Set V6ONLY sockopt for kernel RPC services
Date: Tue, 05 Aug 2008 11:24:50 -0400
Message-ID: <20080805152154.22606.1607.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:43064 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758105AbYHEPZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 11:25:59 -0400
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m75FPvWS004178
	for <netdev@vger.kernel.org>; Tue, 5 Aug 2008 10:25:57 -0500
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m75CbuJV010035
	for <netdev@vger.kernel.org>; Tue, 5 Aug 2008 09:25:57 -0600
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.2/8.14.2) with ESMTP id m75FOoKo022638
	for <netdev@vger.kernel.org>; Tue, 5 Aug 2008 11:24:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It has been suggested that I should unconditionally pre-empt the creation
of user space IPv4 listeners on the same port when the kernel sets up an
IPv6 listener for RPC services.  This series of patches should implement
that.

I'm interested in comments and review -- it's a pretty simple set of
changes that go on top of 2.6.27-rc1.

---

Chuck Lever (2):
      SUNRPC: Set V6ONLY socket option for RPC listener sockets
      SUNRPC: Add address family field to svc_serv data structure


 fs/lockd/svc.c             |    2 +-
 fs/nfs/callback.c          |    3 ++-
 fs/nfsd/nfssvc.c           |    3 ++-
 include/linux/sunrpc/svc.h |    9 +++++----
 net/sunrpc/svc.c           |   11 ++++++-----
 net/sunrpc/svcsock.c       |   12 ++++++++++++
 6 files changed, 28 insertions(+), 12 deletions(-)

-- 
Chuck Lever
