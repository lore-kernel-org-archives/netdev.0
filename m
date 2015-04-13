From: =?UTF-8?q?Pavel=20=C5=A0imerda?= <pavlix@pavlix.net>
Subject: [PATCH 4/7] cbq: fix find syntax in example
Date: Mon, 13 Apr 2015 16:00:58 +0200
Message-ID: <1428933661-8193-4-git-send-email-pavlix@pavlix.net>
References: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, psimerda@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fox.pavlix.net ([84.246.161.104]:47553 "EHLO fox.pavlix.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754249AbbDMOKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 10:10:05 -0400
In-Reply-To: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pavel =C5=A0imerda <psimerda@redhat.com>

Without modification, using the example resulted in the following error=
:

[root@localhost sbin]# cbq restart
find: warning: you have specified the -maxdepth option after a
non-option argument (, but options are not positional (-maxdepth affect=
s
tests specified before it as well as those specified after it).  Please
specify options before other arguments.

find: warning: you have specified the -maxdepth option after a
non-option argument (, but options are not positional (-maxdepth affect=
s
tests specified before it as well as those specified after it).  Please
specify options before other arguments.

**CBQ: failed to compile CBQ configuration!

See also:

 * https://bugzilla.redhat.com/show_bug.cgi?id=3D539232

Reported-by: Mads Kiilerich <mads@kiilerich.com>
Signed-off-by: Pavel =C5=A0imerda <psimerda@redhat.com>
---
 examples/cbq.init-v0.7.3 | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/examples/cbq.init-v0.7.3 b/examples/cbq.init-v0.7.3
index 35a0a05..1bc0d44 100644
--- a/examples/cbq.init-v0.7.3
+++ b/examples/cbq.init-v0.7.3
@@ -578,14 +578,14 @@ cbq_show () {
 ### Check configuration and load DEVICES, DEVFIELDS and CLASSLIST from=
 $1
 cbq_init () {
 	### Get a list of configured classes
-	CLASSLIST=3D`find $1 \( -type f -or -type l \) -name 'cbq-*' \
-		-not -name '*~' -maxdepth 1 -printf "%f\n"| sort`
+	CLASSLIST=3D`find $1 -maxdepth 1 \( -type f -or -type l \) -name 'cbq=
-*' \
+		-not -name '*~' -printf "%f\n"| sort`
 	[ -z "$CLASSLIST" ] &&
 		cbq_failure "no configuration files found in $1!"
=20
 	### Gather all DEVICE fields from $1/cbq-*
-	DEVFIELDS=3D`find $1 \( -type f -or -type l \) -name 'cbq-*' \
-		  -not -name '*~' -maxdepth 1| xargs sed -n 's/#.*//; \
+	DEVFIELDS=3D`find $1 -maxdepth 1 \( -type f -or -type l \) -name 'cbq=
-*' \
+		  -not -name '*~' | xargs sed -n 's/#.*//; \
 		  s/[[:space:]]//g; /^DEVICE=3D[^,]*,[^,]*\(,[^,]*\)\?/ \
 		  { s/.*=3D//; p; }'| sort -u`
 	[ -z "$DEVFIELDS" ] &&
--=20
2.3.5
