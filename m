From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter/iptables and network interface names
Date: Thu, 4 Feb 2010 15:46:38 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1002041542150.13435@obet.zrqbmnf.qr>
References: <4B6AC467.7020209@redhat.com> <alpine.LSU.2.01.1002041528300.13435@obet.zrqbmnf.qr> <4B6ADA3A.7040201@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Thomas Woerner <twoerner@redhat.com>, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:54647 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932625Ab0BDOqn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 09:46:43 -0500
In-Reply-To: <4B6ADA3A.7040201@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2010-02-04 15:31, Patrick McHardy wrote:
>Jan Engelhardt wrote:
>> On Thursday 2010-02-04 13:58, Thomas Woerner wrote:
>>
>>> I think there should be some discussion about interface names and
>>> limits in kernel and netfilter/iptables.
>>>
>>> What do you think?

When was the last time you needed a control character in your
interface name?

>> I think we should cc netdev for a start.
>
>I don't think there is a reason for this limitation in iptables,
>so why not simply remove it?

Like this?

parent 350661a6eb089f3e54e67e022db9e16ea280499f (v1.4.6-7-g350661a)
commit 02020c8fb965bbedae9eb43d9a9b964c46388cc3
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Thu Feb 4 15:46:03 2010 +0100

Lift restrictions on interface names

The kernel has few restrictions.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 xtables.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/xtables.c b/xtables.c
index 63c5db7..f3baf84 100644
--- a/xtables.c
+++ b/xtables.c
@@ -450,7 +450,7 @@ u_int16_t xtables_parse_port(const char *port, const char *proto)
 void xtables_parse_interface(const char *arg, char *vianame,
 			     unsigned char *mask)
 {
-	int vialen = strlen(arg);
+	unsigned int vialen = strlen(arg);
 	unsigned int i;
 
 	memset(mask, 0, IFNAMSIZ);
@@ -462,7 +462,7 @@ void xtables_parse_interface(const char *arg, char *vianame,
 			   " (%i)", arg, IFNAMSIZ-1);
 
 	strcpy(vianame, arg);
-	if ((vialen == 0) || (vialen == 1 && vianame[0] == '+'))
+	if (vialen == 0)
 		memset(mask, 0, IFNAMSIZ);
 	else if (vianame[vialen - 1] == '+') {
 		memset(mask, 0xFF, vialen - 1);
@@ -473,12 +473,11 @@ void xtables_parse_interface(const char *arg, char *vianame,
 		memset(mask, 0xFF, vialen + 1);
 		memset(mask + vialen + 1, 0, IFNAMSIZ - vialen - 1);
 		for (i = 0; vianame[i]; i++) {
-			if (vianame[i] == ':' ||
-			    vianame[i] == '!' ||
-			    vianame[i] == '*') {
+			if (vianame[i] == '/' ||
+			    vianame[i] == ' ') {
 				fprintf(stderr,
 					"Warning: weird character in interface"
-					" `%s' (No aliases, :, ! or *).\n",
+					" `%s' ('/' and ' ' are not allowed by the kernel).\n",
 					vianame);
 				break;
 			}
-- 
# Created with git-export-patch
