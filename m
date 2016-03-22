From: "Varlese, Marco" <marco.varlese@intel.com>
Subject: [PATCH iproute2 v1 1/1] lib/utils: fix get_addr() and get_prefix()
 error messages
Date: Tue, 22 Mar 2016 13:02:02 +0000
Message-ID: <C4896FB061E7DE4AAC93031BDCA044B11A2146FF@IRSMSX108.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.fastabend@gmail.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"Szczerbik, PrzemyslawX" <przemyslawx.szczerbik@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:21473 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756959AbcCVNCJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 09:02:09 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An attempt to add invalid address to interface would print "???" string
instead of the address family name.

For example:
$ ip address add 256.10.166.1/24 dev ens8
Error: ??? prefix is expected rather than "256.10.166.1/24".

$ ip neighbor add proxy 2001:db8::g dev ens8
Error: ??? address is expected rather than "2001:db8::g".

With this patch the output will look like:
$ ip address add 256.10.166.1/24 dev ens8
Error: inet prefix is expected rather than "256.10.166.1/24".

$ ip neighbor add proxy 2001:db8::g dev ens8
Error: inet6 address is expected rather than "2001:db8::g".

Signed-off-by: Przemyslaw Szczerbik <przemyslawx.szczerbik@intel.com>
Signed-off-by: Marco Varlese <marco.varlese@intel.com>
---
lib/utils.c | 4 ++--
1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/utils.c b/lib/utils.c
index fa35f4d..4820de1 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -567,7 +567,7 @@ int get_addr(inet_prefix *dst, const char *arg, int family)
{
        if (get_addr_1(dst, arg, family)) {
                fprintf(stderr, "Error: %s address is expected rather than \"%s\".\n",
-                               family_name(family) ,arg);
+                               family_name(dst->family), arg);
                exit(1);
        }
        return 0;
@@ -581,7 +581,7 @@ int get_prefix(inet_prefix *dst, char *arg, int family)
        }
        if (get_prefix_1(dst, arg, family)) {
                fprintf(stderr, "Error: %s prefix is expected rather than \"%s\".\n",
-                               family_name(family) ,arg);
+                               family_name(dst->family), arg);
                exit(1);
        }
        return 0;
