From: Lucas Bates <lucasb@mojatatu.com>
Subject: [PATCH net-next 4/4] tc-testing: fix the -l argument bug in tdc.py script
Date: Wed, 11 Oct 2017 17:16:54 -0400
Message-ID: <1507756614-30333-5-git-send-email-lucasb@mojatatu.com>
References: <1507756614-30333-1-git-send-email-lucasb@mojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jhs@mojatatu.com, aring@mojatatu.com, mrv@mojatatu.com,
        Lucas Bates <lucasb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:50496 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757140AbdJKVRU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:17:20 -0400
Received: by mail-io0-f195.google.com with SMTP id 97so3302233iok.7
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 14:17:20 -0700 (PDT)
In-Reply-To: <1507756614-30333-1-git-send-email-lucasb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug in the tdc script, where executing tdc
with the -l argument would cause the tests to start running
as opposed to listing all the known test cases.

Signed-off-by: Lucas Bates <lucasb@mojatatu.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tools/testing/selftests/tc-testing/tdc.py | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/testing/selftests/tc-testing/tdc.py b/tools/testing/selftests/tc-testing/tdc.py
index cd61b78..d2391df 100755
--- a/tools/testing/selftests/tc-testing/tdc.py
+++ b/tools/testing/selftests/tc-testing/tdc.py
@@ -49,7 +49,7 @@ def exec_cmd(command, nsonly=True):
         stderr=subprocess.PIPE)
     (rawout, serr) = proc.communicate()

-    if proc.returncode != 0:
+    if proc.returncode != 0 and len(serr) > 0:
         foutput = serr.decode("utf-8")
     else:
         foutput = rawout.decode("utf-8")
@@ -203,7 +203,7 @@ def set_args(parser):
                         help='Run tests only from the specified category, or if no category is specified, list known categories.')
     parser.add_argument('-f', '--file', type=str,
                         help='Run tests from the specified file')
-    parser.add_argument('-l', '--list', type=str, nargs='?', const="", metavar='CATEGORY',
+    parser.add_argument('-l', '--list', type=str, nargs='?', const="++", metavar='CATEGORY',
                         help='List all test cases, or those only within the specified category')
     parser.add_argument('-s', '--show', type=str, nargs=1, metavar='ID', dest='showID',
                         help='Display the test case with specified id')
@@ -357,10 +357,10 @@ def set_operation_mode(args):
     testcases = get_categorized_testlist(alltests, ucat)

     if args.list:
-        if (len(args.list) == 0):
+        if (args.list == "++"):
             list_test_cases(alltests)
             exit(0)
-        elif(len(args.list > 0)):
+        elif(len(args.list) > 0):
             if (args.list not in ucat):
                 print("Unknown category " + args.list)
                 print("Available categories:")
