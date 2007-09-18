From: Holger Eitzenberger <holger@my-eitzenberger.de>
Subject: Re: [FIX NETLINK] properly check arguments to netlink_bind()
Date: Tue, 18 Sep 2007 23:05:52 +0200
Message-ID: <876427elan.fsf@kruemel.my-eitzenberger.de>
References: <87fy1belij.fsf@kruemel.my-eitzenberger.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:53110 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbXIRVFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 17:05:55 -0400
Received: from holger by kruemel.my-eitzenberger.de with local (Exim 4.50)
	id 1IXkGW-000673-N6
	for netdev@vger.kernel.org; Tue, 18 Sep 2007 23:05:52 +0200
In-Reply-To: <87fy1belij.fsf@kruemel.my-eitzenberger.de> (Holger
 Eitzenberger's message of "Tue, 18 Sep 2007 23:01:08 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=

Holger Eitzenberger <holger@my-eitzenberger.de> writes:

> while going through going netlink code I found out that netlink_bind()
> does not properly check bind parameters.  I checked both 2.6.23-rc1 as
> well as 2.6.16.53, both are affected.
>
> With a small test prog I wasn't able to crash my maschine though, but
> data was accessed out of bounds.

See my attached patch, thanks.

  /holger


--=-=-=
Content-Disposition: inline;
  filename=NETLINK-Check-for-correct-bind-parameters.diff
Content-Description: netlink fix

[NETLINK] Check for correct bind parameters

Before this change it was possible to pass less than sockaddr_nl
bytes, which might lead to arbitrary data being accessed in
netlink_bind().

Signed-off-by: Holger Eitzenberger <holger@my-eitzenberger.de>

---
commit 53ba94ab22cc3338d915d684ba1012fa0419ff14
tree 3a1b1dc6cb5dacac99722b9f96fe3ba4b2d29bde
parent f695baf2df9e0413d3521661070103711545207a
author Holger Eitzenberger <holger@my-eitzenberger.de> Mon, 17 Sep 2007 22:15:37 +0200
committer Holger Eitzenberger <holger@elmo.(none)> Mon, 17 Sep 2007 22:15:37 +0200

 net/netlink/af_netlink.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 5681ce3..425543d 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -598,6 +598,9 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr, int addr_len
 	struct sockaddr_nl *nladdr = (struct sockaddr_nl *)addr;
 	int err;
 
+	if (addr < sizeof(struct sockaddr_nl))
+		return -EINVAL;
+
 	if (nladdr->nl_family != AF_NETLINK)
 		return -EINVAL;
 

--=-=-=--
