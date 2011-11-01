From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 11/21] Add more test cases for command-line parsing
Date: Tue, 1 Nov 2011 23:17:32 +0000
Message-ID: <1320189452.2758.41.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38210 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553Ab1KAXRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:17:36 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These test cases currently fail.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 test-cmdline.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/test-cmdline.c b/test-cmdline.c
index 88591df..7dd3b7c 100644
--- a/test-cmdline.c
+++ b/test-cmdline.c
@@ -55,8 +55,10 @@ static struct test_case {
 	{ 1, "-s devname msglvl hw" },
 	{ 0, "--change devname speed 100 duplex half port tp autoneg on advertise 0x1 phyad 1 xcvr external wol p sopass 01:23:45:67:89:ab msglvl 1" },
 	{ 1, "-s devname foo" },
+	{ 1, "-s" },
 	{ 0, "-a devname" },
 	{ 0, "--show-pause devname" },
+	{ 1, "-a" },
 	/* Many other sub-commands use parse_generic_cmdline() and
 	 * don't need to be check in that much detail. */
 	{ 0, "-A devname autoneg on" },
@@ -65,6 +67,7 @@ static struct test_case {
 	{ 0, "--pause devname rx off" },
 	{ 0, "-A devname tx on rx on autoneg off" },
 	{ 1, "--pause devname foo on" },
+	{ 1, "-A" },
 	{ 0, "-c devname" },
 	{ 0, "--show-coalesce devname" },
 	{ 0, "-C devname adaptive-rx on adaptive-tx off rx-usecs 1 rx-frames 2 rx-usecs-irq 3 rx-frames-irq 4 tx-usecs 5 tx-frames 6 tx-usecs-irq 7 tx-frames-irq 8 stats-block-usecs 9 pkt-rate-low 10" },
@@ -72,42 +75,53 @@ static struct test_case {
 	{ 1, "-C devname adaptive-rx foo" },
 	{ 1, "--coalesce devname adaptive-rx" },
 	{ 1, "-C devname foo on" },
+	{ 1, "-C" },
 	{ 0, "-g devname" },
 	{ 0, "--show-ring devname" },
+	{ 1, "-g" },
 	{ 0, "-G devname rx 1 rx-mini 2 rx-jumbo 3 tx 4" },
 	{ 0, "--set-ring devname rx 1 rx-mini 2 rx-jumbo 3 tx 4" },
 	{ 1, "-G devname rx foo" },
 	{ 1, "--set-ring devname rx" },
 	{ 1, "-G devname foo 1" },
+	{ 1, "-G" },
 	{ 0, "-k devname" },
 	{ 0, "--show-offload devname" },
+	{ 1, "-k" },
 	{ 0, "-K devname rx on tx off sg on tso off ufo on gso off gro on" },
 	{ 0, "--offload devname lro off rxvlan on txvlan off ntuple on rxhash off" },
 	{ 1, "-K devname rx foo" },
 	{ 1, "--offload devname rx" },
 	{ 1, "-K devname foo on" },
+	{ 1, "-K" },
 	{ 0, "-i devname" },
 	{ 0, "--driver devname" },
+	{ 1, "-i" },
 	{ 0, "-d devname" },
 	{ 0, "--register-dump devname raw on file foo" },
 	{ 1, "-d devname raw foo" },
 	{ 1, "--register-dump devname file" },
 	{ 1, "-d devname foo" },
+	{ 1, "-d" },
 	{ 0, "-e devname" },
 	{ 0, "--eeprom-dump devname raw on offset 1 length 2" },
 	{ 1, "-e devname raw foo" },
 	{ 1, "--eeprom-dump devname offset foo" },
 	{ 1, "-e devname length" },
 	{ 1, "--eeprom-dump devname foo" },
+	{ 1, "-e" },
 	{ 0, "-E devname" },
 	{ 0, "--change-eeprom devname magic 0x87654321 offset 0 value 1" },
 	{ 0, "-E devname magic 0x87654321 offset 0 length 2" },
+	{ 1, "-E" },
 	{ 0, "-r devname" },
 	{ 0, "--negotiate devname" },
+	{ 1, "-r" },
 	{ 0, "-p devname" },
 	{ 0, "--identify devname 1" },
 	{ 1, "-p devname 1 foo" },
 	{ 1, "--identify devname foo" },
+	{ 1, "-p" },
 	/* Argument parsing for -t is specialised */
 	{ 0, "-t devname" },
 	{ 0, "--test devname online" },
@@ -115,16 +129,20 @@ static struct test_case {
 	{ 1, "--test devname online foo" },
 	{ 0, "-S devname" },
 	{ 0, "--statistics devname" },
+	{ 1, "-S" },
 	/* Argument parsing for -n is specialised */
 	{ 0, "-n devname rx-flow-hash tcp4" },
 	{ 0, "--show-nfc devname rx-flow-hash udp6" },
 	{ 1, "-n devname rx-flow-hash foo" },
 	{ 1, "--show-nfc devname rx-flow-hash" },
 	{ 1, "-n devname foo" },
+	{ 1, "-n" },
 	/* Argument parsing for -f is specialised */
 	{ 1, "-f devname" },
 	{ 0, "--flash devname filename" },
 	{ 0, "-f devname filename 1" },
+	{ 1, "-f devname filename 1 foo" },
+	{ 1, "-f" },
 	/* Argument parsing for -N is specialised */
 	{ 0, "-N devname rx-flow-hash tcp4 mvtsdfn" },
 	{ 0, "--config-nfc devname rx-flow-hash tcp4 r" },
@@ -132,8 +150,10 @@ static struct test_case {
 	{ 1, "--config-nfc devname rx-flow-hash foo" },
 	{ 1, "-N devname rx-flow-hash" },
 	{ 1, "--config-nfc devname foo" },
+	{ 1, "-N" },
 	{ 0, "-x devname" },
 	{ 0, "--show-rxfh-indir devname" },
+	{ 1, "-x" },
 	/* Argument parsing for -X is specialised */
 	{ 0, "-X devname equal 2" },
 	{ 0, "--set-rxfh-indir devname equal 256" },
@@ -142,6 +162,7 @@ static struct test_case {
 	{ 1, "-X devname equal" },
 	{ 0, "--set-rxfh-indir devname weight 1 2 3 4" },
 	{ 1, "-X devname foo" },
+	{ 1, "-X" },
 	/* Argument parsing for -U is specialised */
 	{ 0, "-U devname delete 1" },
 	{ 1, "--config-ntuple devname delete foo" },
@@ -160,23 +181,30 @@ static struct test_case {
 	{ 1, "-U devname flow-type foo" },
 	{ 1, "--config-ntuple devname flow-type" },
 	{ 1, "-U devname foo" },
+	{ 1, "-U" },
 	{ 0, "-P devname" },
 	{ 0, "--show-permaddr devname" },
+	{ 1, "-P" },
 	{ 0, "-w devname" },
 	{ 0, "--get-dump devname data filename" },
 	{ 0, "-w devname data filename" },
 	{ 1, "--get-dump devname data" },
 	{ 1, "-w devname foo" },
+	{ 1, "-w" },
 	{ 0, "-W devname 1" },
 	{ 0, "--set-dump devname 2" },
+	{ 1, "-W devname 1 foo" },
 	{ 1, "-W devname foo" },
+	{ 1, "-W" },
 	{ 0, "-l devname" },
 	{ 0, "--show-channels devname" },
+	{ 1, "-l" },
 	{ 0, "-L devname rx 1 tx 2 other 3 combined 4" },
 	{ 0, "--set-channels devname rx 1 tx 2 other 3 combined 4" },
 	{ 1, "-L devname rx foo" },
 	{ 1, "--set-channels devname rx" },
 	{ 0, "-L devname" },
+	{ 1, "-L" },
 	{ 0, "-h" },
 	{ 0, "--help" },
 	{ 0, "--version" },
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
