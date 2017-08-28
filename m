From: Alexander Aring <aring@mojatatu.com>
Subject: [PATCH net-next 3/3] tc-testing: add test for testing ife type
Date: Mon, 28 Aug 2017 15:03:15 -0400
Message-ID: <20170828190315.26646-4-aring@mojatatu.com>
References: <20170828190315.26646-1-aring@mojatatu.com>
Cc: yotamg@mellanox.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        lucasb@mojatatu.com, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org,
        Alexander Aring <aring@mojatatu.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35778 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751269AbdH1TEe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:04:34 -0400
Received: by mail-io0-f196.google.com with SMTP id c18so1090045ioj.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 12:04:34 -0700 (PDT)
In-Reply-To: <20170828190315.26646-1-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new testcase for the IFE type setting in tc. In case
of user specified the type it will check if the ife is correctly
configured to react on it. If it's not specified the default IFE type
should be used.

Signed-off-by: Alexander Aring <aring@mojatatu.com>
---
 .../tc-testing/tc-tests/actions/tests.json         | 50 ++++++++++++++++++++++
 1 file changed, 50 insertions(+)

diff --git a/tools/testing/selftests/tc-testing/tc-tests/actions/tests.json b/tools/testing/selftests/tc-testing/tc-tests/actions/tests.json
index af519bc97a8e..6973bdc5b5bf 100644
--- a/tools/testing/selftests/tc-testing/tc-tests/actions/tests.json
+++ b/tools/testing/selftests/tc-testing/tc-tests/actions/tests.json
@@ -1111,5 +1111,55 @@
         "teardown": [
             "$TC actions flush action gact"
         ]
+    },
+    {
+        "id": "a568",
+        "name": "Add action with ife type",
+        "category": [
+            "actions",
+            "ife"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action ife",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action ife encode type 0xDEAD index 1"
+        ],
+        "cmdUnderTest": "$TC actions get action ife index 1",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions get action ife index 1",
+        "matchPattern": "type 0xDEAD",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action ife"
+        ]
+    },
+    {
+        "id": "b983",
+        "name": "Add action without ife type",
+        "category": [
+            "actions",
+            "ife"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action ife",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action ife encode index 1"
+        ],
+        "cmdUnderTest": "$TC actions get action ife index 1",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions get action ife index 1",
+        "matchPattern": "type 0xED3E",
+        "matchCount": "1",
+        "teardown": [
+            "$TC actions flush action ife"
+        ]
     }
 ]
\ No newline at end of file
-- 
2.11.0
