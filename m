From: Patrick McHardy <kaber@trash.net>
Subject: Re: more iproute2 issues (not critical)
Date: Sat, 31 Mar 2007 16:16:56 +0200
Message-ID: <460E6D58.8090701@trash.net>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net> <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net> <20070322101224.3e6bb899@freekitty> <20070331021401.M17326@visp.net.lb> <20070331023011.M8101@visp.net.lb>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080803030100060609060203"
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62724 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693AbXCaORK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2007 10:17:10 -0400
In-Reply-To: <20070331023011.M8101@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080803030100060609060203
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Denys wrote:
> Ooops, sorry, it seems my fault, no library exist on this system.
> But i guess it must not coredump in this case? Is it possible to check if 
> library not exist and just print some nice message?
> It is trivial i guess.


The problem is that lib_dir is NULL when calling get_target_names.
This patch fixes it.


--------------080803030100060609060203
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPROUTE]: m_ipt: fix crash when dumping rules

lib_dir is NULL when calling get_target_name, causing a NULL pointer
dereference in the strlen call.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 5093ef7504b7f3d76ec421c5193d11d0e9791a8d
tree 4dfa97ecd6aa01f33334f605f152a0d7da2ccde9
parent ab4c2f14fb93700c9aefeb02ed9918565ba332a1
author Patrick McHardy <kaber@trash.net> Sat, 31 Mar 2007 16:14:38 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 31 Mar 2007 16:14:38 +0200

 tc/m_ipt.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tc/m_ipt.c b/tc/m_ipt.c
index 38d2311..76fa768 100644
--- a/tc/m_ipt.c
+++ b/tc/m_ipt.c
@@ -506,6 +506,10 @@ print_ipt(struct action_util *au,FILE * f, struct rtattr *arg)
 	if (arg == NULL)
 		return -1;
 
+	lib_dir = getenv("IPTABLES_LIB_DIR");
+	if (!lib_dir)
+		lib_dir = IPT_LIB_DIR;
+
 	parse_rtattr_nested(tb, TCA_IPT_MAX, arg);
 
 	if (tb[TCA_IPT_TABLE] == NULL) {

--------------080803030100060609060203--
