From: Lucas Bates <lucasb@mojatatu.com>
Subject: [PATCH net-next v2 1/4] tc-testing: Add test cases for flushing actions
Date: Fri, 13 Oct 2017 17:51:22 -0400
Message-ID: <1507931485-1814-2-git-send-email-lucasb@mojatatu.com>
References: <1507931485-1814-1-git-send-email-lucasb@mojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jhs@mojatatu.com, aring@mojatatu.com, mrv@mojatatu.com,
        Lucas Bates <lucasb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:47370 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751624AbdJMVvk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 17:51:40 -0400
Received: by mail-it0-f51.google.com with SMTP id p138so12914031itp.2
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 14:51:40 -0700 (PDT)
In-Reply-To: <1507931485-1814-1-git-send-email-lucasb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tests for flushing gact and mirred were missing. This patch
adds test cases to explicitly test the flush of any installed
gact/mirred actions.

Signed-off-by: Lucas Bates <lucasb@mojatatu.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 .../tc-testing/tc-tests/actions/tests.json         | 49 +++++++++++++++++++++-
 1 file changed, 48 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/tc-testing/tc-tests/actions/tests.json b/tools/testing/selftests/tc-testing/tc-tests/actions/tests.json
index 6973bdc..2ea0065 100644
--- a/tools/testing/selftests/tc-testing/tc-tests/actions/tests.json
+++ b/tools/testing/selftests/tc-testing/tc-tests/actions/tests.json
@@ -246,6 +246,27 @@
         ]
     },
     {
+        "id": "3edf",
+        "name": "Flush gact actions",
+        "category": [
+            "actions",
+            "gact"
+        ],
+        "setup": [
+            "$TC actions add action reclassify index 101",
+            "$TC actions add action reclassify index 102",
+            "$TC actions add action reclassify index 103",
+            "$TC actions add action reclassify index 104",
+            "$TC actions add action reclassify index 105"
+        ],
+        "cmdUnderTest": "$TC actions flush action gact",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action gact",
+        "matchPattern": "action order [0-9]*: gact action reclassify",
+        "matchCount": "0",
+        "teardown": []
+    },
+    {
         "id": "63ec",
         "name": "Delete pass action",
         "category": [
@@ -469,6 +490,32 @@
         ]
     },
     {
+        "id": "58c3",
+        "name": "Flush mirred actions",
+        "category": [
+            "actions",
+            "mirred"
+        ],
+        "setup": [
+            [
+                "$TC actions flush action mirred",
+                0,
+                1,
+                255
+            ],
+            "$TC actions add action mirred egress mirror index 1 dev lo",
+            "$TC actions add action mirred egress redirect index 2 dev lo"
+        ],
+        "cmdUnderTest": "$TC actions show action mirred",
+        "expExitCode": "0",
+        "verifyCmd": "$TC actions list action mirred",
+        "matchPattern": "[Mirror|Redirect] to device lo",
+        "matchCount": "0",
+        "teardown": [
+            "$TC actions flush action mirred"
+        ]
+    },
+    {
         "id": "d7c0",
         "name": "Add invalid mirred direction",
         "category": [
@@ -1162,4 +1209,4 @@
             "$TC actions flush action ife"
         ]
     }
-]
\ No newline at end of file
+]
