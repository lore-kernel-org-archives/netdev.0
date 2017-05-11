From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 7/7] bpf: Adjust test_verifier for alignment changes.
Date: Thu, 11 May 2017 12:06:18 -0400 (EDT)
Message-ID: <20170511.120618.525583843526792579.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51606 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933697AbdEKQGZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 12:06:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that the verifier properly tracks pointer alignment,
many of the tests here no longer need to specify the test
flag F_NEEDS_EFFICIENT_UNALIGNED_ACCESS.

The are only two tests remaining which need it and those
intentionally try to perform unaligned accesses.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 tools/testing/selftests/bpf/test_verifier.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 3773562..5318fbc 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -3117,7 +3117,6 @@ static struct bpf_test tests[] = {
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"valid map access into an array with a variable",
@@ -3141,7 +3140,6 @@ static struct bpf_test tests[] = {
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"valid map access into an array with a signed variable",
@@ -3169,7 +3167,6 @@ static struct bpf_test tests[] = {
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid map access into an array with a constant",
@@ -3211,7 +3208,6 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is outside of the array range",
 		.result_unpriv = REJECT,
 		.result = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid map access into an array with a variable",
@@ -3235,7 +3231,6 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result_unpriv = REJECT,
 		.result = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid map access into an array with no floor check",
@@ -3262,7 +3257,6 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result_unpriv = REJECT,
 		.result = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid map access into an array with a invalid max check",
@@ -3289,7 +3283,6 @@ static struct bpf_test tests[] = {
 		.errstr = "invalid access to map value, value_size=48 off=44 size=8",
 		.result_unpriv = REJECT,
 		.result = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid map access into an array with a invalid max check",
@@ -3319,7 +3312,6 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result_unpriv = REJECT,
 		.result = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"multiple registers share map_lookup_elem result",
@@ -3443,7 +3435,6 @@ static struct bpf_test tests[] = {
 		.result = REJECT,
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result_unpriv = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"constant register |= constant should keep constant type",
@@ -4396,7 +4387,6 @@ static struct bpf_test tests[] = {
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result = ACCEPT,
 		.result_unpriv = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"helper access to variable memory: stack, bitwise AND + JMP, correct bounds",
@@ -4835,7 +4825,6 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result = REJECT,
 		.result_unpriv = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid range check",
@@ -4867,7 +4856,6 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result = REJECT,
 		.result_unpriv = REJECT,
-		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"map in map access",
@@ -5070,7 +5058,7 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 
 	reject_from_alignment = fd_prog < 0 &&
 				(test->flags & F_NEEDS_EFFICIENT_UNALIGNED_ACCESS) &&
-				strstr(bpf_vlog, "Unknown alignment.");
+				strstr(bpf_vlog, "misaligned value access");
 #ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 	if (reject_from_alignment) {
 		printf("FAIL\nFailed due to alignment despite having efficient unaligned access: '%s'!\n",
-- 
2.1.2.532.g19b5d50
