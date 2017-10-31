From: "Brenda J. Butler" <bjb@mojatatu.com>
Subject: [PATCH net-next] tc-testing: very simple example test cases
Date: Tue, 31 Oct 2017 14:25:46 -0400
Message-ID: <20171031182546.9614-1-bjb@mojatatu.com>
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        chrism@mellanox.com, lucasb@mojatatu.com, aring@mojatatu.com,
        mrv@mojatatu.com, netdev@vger.kernel.org,
        "Brenda J. Butler" <bjb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:45135 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932543AbdJaSZ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:25:56 -0400
Received: by mail-io0-f194.google.com with SMTP id i38so846671iod.2
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:25:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of documentation, supply some very simple test cases
to illustrate how test cases work.  One test case shows
commands in the setup, command, verify and teardown stages.
Other test cases show how to have a working test case that
does not have commands in the setup, verify and/or teardown
stages.

Specifically, the command lists for setup and teardown can
be empty.  And the verify command must have a command, but
it can be /bin/true.  The regex must have a string, we
recommend a single space, and the count of matches must be
zero if you do not want to use the match feature of verify.
Verify will always look for a return code of success (0)
so we give /bin/true when we do not want to make a check
there.

Also, update the documentation for testcases to be more
specific in the cases of:

    - accepting non-success return codes in setup and
      teardown stages
    - how to write the test when no setup, teardown
      and/or verify are desired.

To run the example test cases:

    $ sudo -E ./tdc.py -f creating-testcases/example.json -l
    1f: (example) simple test to test framework
    2f: (example) simple test, no need for verify
    3f: (example) simple test, no need for setup or teardown (or verify)
    $ sudo -E ./tdc.py -f creating-testcases/example.json
    Test 1f: simple test to test framework
    Test 2f: simple test, no need for verify
    Test 3f: simple test, no need for setup or teardown (or verify)
    All test results:

    1..3
    ok 1 1f simple test to test framework
    ok 2 2f simple test, no need for verify
    ok 3 3f simple test, no need for setup or teardown (or verify)

    $

Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
---

file AddingTestCases.txt
    clarification of what is expected/allowed in setup/teardown
file example.json
    a few working simple test cases
file template.json
    examples of accepting more than one return code for setup/teardown commands

This patch was formerly sent as part of a 15-patch series.  It is being
split off as a stand-alone patch.  It has been augmented with more
documentation, examples, and a more descriptive commit message.

 .../creating-testcases/AddingTestCases.txt         | 12 +++++
 .../tc-testing/creating-testcases/example.json     | 55 ++++++++++++++++++++++
 .../tc-testing/creating-testcases/template.json    | 15 +++++-
 3 files changed, 80 insertions(+), 2 deletions(-)
 create mode 100644 tools/testing/selftests/tc-testing/creating-testcases/example.json

diff --git a/tools/testing/selftests/tc-testing/creating-testcases/AddingTestCases.txt b/tools/testing/selftests/tc-testing/creating-testcases/AddingTestCases.txt
index 4e09257bc443..00438331ba47 100644
--- a/tools/testing/selftests/tc-testing/creating-testcases/AddingTestCases.txt
+++ b/tools/testing/selftests/tc-testing/creating-testcases/AddingTestCases.txt
@@ -34,6 +34,12 @@ category:     A list of single-word descriptions covering what the command
 setup:        The list of commands required to ensure the command under test
               succeeds. For example: if testing a filter, the command to create
               the qdisc would appear here.
+	      This list can be empty.
+	      Each command can be a string to be executed, or a list consisting
+	      of a string which is a command to be executed, followed by 1 or
+	      more acceptable exit codes for this command.
+	      If only a string is given for the command, then an exit code of 0
+	      will be expected.
 cmdUnderTest: The tc command being tested itself.
 expExitCode:  The code returned by the command under test upon its termination.
               tdc will compare this value against the actual returned value.
@@ -49,6 +55,12 @@ matchCount:   How many times the regex in matchPattern should match. A value
 teardown:     The list of commands to clean up after the test is completed.
               The environment should be returned to the same state as when
               this test was started: qdiscs deleted, actions flushed, etc.
+	      This list can be empty.
+	      Each command can be a string to be executed, or a list consisting
+	      of a string which is a command to be executed, followed by 1 or
+	      more acceptable exit codes for this command.
+	      If only a string is given for the command, then an exit code of 0
+	      will be expected.
 
 
 SETUP/TEARDOWN ERRORS
diff --git a/tools/testing/selftests/tc-testing/creating-testcases/example.json b/tools/testing/selftests/tc-testing/creating-testcases/example.json
new file mode 100644
index 000000000000..5ec501200970
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/creating-testcases/example.json
@@ -0,0 +1,55 @@
+[
+    {
+        "id": "1f",
+        "name": "simple test to test framework",
+        "category": [
+            "example"
+        ],
+        "setup": [
+            "mkdir mytest"
+        ],
+        "cmdUnderTest": "touch mytest/blorfl",
+        "expExitCode": "0",
+        "verifyCmd": "ls mytest/* | grep '[b]lorfl'",
+        "matchPattern": "orfl",
+        "matchCount": "1",
+        "teardown": [
+            "rm -rf mytest"
+        ]
+    },
+    {
+        "id": "2f",
+        "name": "simple test, no need for verify",
+        "category": [
+            "example"
+        ],
+        "setup": [
+            "mkdir mytest",
+            "touch mytest/blorfl"
+        ],
+        "cmdUnderTest": "ls mytest/blorfl",
+        "expExitCode": "0",
+        "verifyCmd": "/bin/true",
+        "matchPattern": " ",
+        "matchCount": "0",
+        "teardown": [
+            "rm -rf mytest"
+        ]
+    },
+    {
+        "id": "3f",
+        "name": "simple test, no need for setup or teardown (or verify)",
+        "category": [
+            "example"
+        ],
+        "setup": [
+        ],
+        "cmdUnderTest": "ip l l lo",
+        "expExitCode": "0",
+        "verifyCmd": "/bin/true",
+        "matchPattern": " ",
+        "matchCount": "0",
+        "teardown": [
+        ]
+    }
+]
diff --git a/tools/testing/selftests/tc-testing/creating-testcases/template.json b/tools/testing/selftests/tc-testing/creating-testcases/template.json
index 87971744bdd4..8b99b86d65bd 100644
--- a/tools/testing/selftests/tc-testing/creating-testcases/template.json
+++ b/tools/testing/selftests/tc-testing/creating-testcases/template.json
@@ -26,7 +26,13 @@
             ""
         ],
         "setup": [
-            ""
+            "",
+	    [
+		"",
+		0,
+		1,
+		255
+	    ]
         ],
         "cmdUnderTest": "",
         "expExitCode": "",
@@ -34,7 +40,12 @@
         "matchPattern": "",
         "matchCount": "",
         "teardown": [
-            ""
+            "",
+	    [
+		"",
+		0,
+		255
+            ]
         ]
     }
 ]
-- 
2.15.0.rc0
