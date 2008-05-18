From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] RFC: raw IPv6 address parsing in NFS client
Date: Sun, 18 May 2008 17:19:55 -0400
Message-ID: <20080518210625.13450.71349.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:57828 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbYERVUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 17:20:02 -0400
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m4ILJxsV015539
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 16:19:59 -0500
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m4HFqUHm015679
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 15:19:58 -0600
Received: from ellison.1015granger.net (ellison.1015granger.net [127.0.0.1])
	by ellison.1015granger.net (8.14.2/8.14.2) with ESMTP id m4ILJtR9014081
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 17:19:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi-

I'm interested in some review of the following four patches which add to
the kernel's NFS client the ability to parse IPv6 addresses in presentation
format.

Namely, it adds the following:

1.  If the user passes in an IPv6 address as the server name, the colons
    in the address will confuse the logic that splits the device name
    into a server hostname and an export path.   We'll use square brackets
    around IPv6 server addresses to "escape" the colons, as does Solaris.

2.  If the user passes in a link-local IPv6 address as the server name,
    an interface index is also necessary.  We'll use the "%id" suffix on
    the address to pass in the index, and plant that in the sockaddr's
    sin6_scope_id field.

In addition to the following patches in email, a git repo with these
same patches already applied can be found here:

	linux-nfs.org:exports/cel-2.6.git

The basic questions:

Are these reasonable conventions to follow?  Is the parsing logic adequate?
Is there anything I'm forgetting?

Thanks for any review.

---

Chuck Lever (4):
      NFS: handle interface identifiers in incoming IPv6 addresses
      NFS: Add string length argument to nfs_parse_server_address
      NFS: Support raw IPv6 address hostnames during NFS mount operation
      NFS: Use common device name parsing logic for NFSv4 and NFSv2/v3


 fs/nfs/super.c |  311 ++++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 236 insertions(+), 75 deletions(-)
