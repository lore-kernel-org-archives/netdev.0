From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net] selftests/net: rxtimestamp: Fix an off by one
Date: Thu, 5 Oct 2017 15:53:47 +0300
Message-ID: <20171005125347.otplfss4mo7hfopv@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willem de Bruijn <willemb@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Shuah Khan <shuah@kernel.org>, Mike Maloney <maloney@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:33669 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdJEMyC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 08:54:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The > should be >= so that we don't write one element beyond the end of
the array.

Fixes: 16e781224198 ("selftests/net: Add a test to validate behavior of rx timestamps")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/tools/testing/selftests/networking/timestamping/rxtimestamp.c b/tools/testing/selftests/networking/timestamping/rxtimestamp.c
index 00f286661dcd..dd4162fc0419 100644
--- a/tools/testing/selftests/networking/timestamping/rxtimestamp.c
+++ b/tools/testing/selftests/networking/timestamping/rxtimestamp.c
@@ -341,7 +341,7 @@ int main(int argc, char **argv)
 			return 0;
 		case 'n':
 			t = atoi(optarg);
-			if (t > ARRAY_SIZE(test_cases))
+			if (t >= ARRAY_SIZE(test_cases))
 				error(1, 0, "Invalid test case: %d", t);
 			all_tests = false;
 			test_cases[t].enabled = true;
