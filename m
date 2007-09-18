From: Holger Eitzenberger <holger@my-eitzenberger.de>
Subject: Re: [FIX NETLINK] properly check arguments to netlink_bind()
Date: Tue, 18 Sep 2007 23:14:02 +0200
Message-ID: <871wcvekx1.fsf@kruemel.my-eitzenberger.de>
References: <87fy1belij.fsf@kruemel.my-eitzenberger.de>
	<876427elan.fsf@kruemel.my-eitzenberger.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:63034 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897AbXIRVOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 17:14:04 -0400
Received: from holger by kruemel.my-eitzenberger.de with local (Exim 4.50)
	id 1IXkOQ-000687-AI
	for netdev@vger.kernel.org; Tue, 18 Sep 2007 23:14:02 +0200
In-Reply-To: <876427elan.fsf@kruemel.my-eitzenberger.de> (Holger
 Eitzenberger's message of "Tue, 18 Sep 2007 23:05:52 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=

The previous patchlet wasn't correct, please apply this one.

Sorry for the noise.

  /holger


--=-=-=
Content-Disposition: inline;
  filename=NETLINK-Check-for-correct-bind-parameters.diff
Content-Description: netlink bind fix

[NETLINK] Check for correct bind parameters

Before this change it was possible to pass less than sockaddr_nl
bytes, which might lead to arbitrary data being accessed in
netlink_bind().

Take two.

Signed-off-by: Holger Eitzenberger <holger@my-eitzenberger.de>

---
commit 3155c34167184c31afeac2a061c0e0b9cd401d56
tree b5efe4234a5835e823b6b024f8d96e56f4abfd18
parent f695baf2df9e0413d3521661070103711545207a
author Holger Eitzenberger <holger@my-eitzenberger.de> Tue, 18 Sep 2007 23:10:11 +0200
committer Holger Eitzenberger <holger@elmo.(none)> Tue, 18 Sep 2007 23:10:11 +0200

 net/netlink/af_netlink.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 5681ce3..5aaa9a7 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -598,6 +598,9 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr, int addr_len
 	struct sockaddr_nl *nladdr = (struct sockaddr_nl *)addr;
 	int err;
 
+	if (addr_len < sizeof(struct sockaddr_nl))
+		return -EINVAL;
+
 	if (nladdr->nl_family != AF_NETLINK)
 		return -EINVAL;
 

--=-=-=--
