From: "Brenda J. Butler" <bjb@mojatatu.com>
Subject: [PATCH net-next] tc-testing: "show" action shows all selected tests
Date: Tue, 31 Oct 2017 14:30:16 -0400
Message-ID: <20171031183016.9981-1-bjb@mojatatu.com>
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        chrism@mellanox.com, lucasb@mojatatu.com, aring@mojatatu.com,
        mrv@mojatatu.com, netdev@vger.kernel.org,
        "Brenda J. Butler" <bjb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:49563 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932652AbdJaSaW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:30:22 -0400
Received: by mail-io0-f195.google.com with SMTP id n137so842802iod.6
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:30:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The -s "show" option takes an argument to specify which test
to show.  Change the option so it does not take an argument,
but outputs all the tests that were selected with the other
arguments.

It is still possible to output a single test, by using the -e
option, but now more than one test can be displayed with
one command.

Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
---
 tools/testing/selftests/tc-testing/tdc.py        |  7 ++++---
 tools/testing/selftests/tc-testing/tdc_helper.py | 12 +++---------
 2 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/tools/testing/selftests/tc-testing/tdc.py b/tools/testing/selftests/tc-testing/tdc.py
index 5508730ee1ea..26dcf8dd106c 100755
--- a/tools/testing/selftests/tc-testing/tdc.py
+++ b/tools/testing/selftests/tc-testing/tdc.py
@@ -211,8 +211,8 @@ def set_args(parser):
                         help='Run tests from the specified file')
     parser.add_argument('-l', '--list', type=str, nargs='?', const="++", metavar='CATEGORY',
                         help='List all test cases, or those only within the specified category')
-    parser.add_argument('-s', '--show', type=str, nargs=1, metavar='ID', dest='showID',
-                        help='Display the test case with specified id')
+    parser.add_argument('-s', '--show', action='store_true', dest='showID',
+                        help='Display the selected test cases')
     parser.add_argument('-e', '--execute', type=str, nargs=1, metavar='ID',
                         help='Execute the single test case with specified ID')
     parser.add_argument('-i', '--id', action='store_true', dest='gen_id',
@@ -344,7 +344,8 @@ def set_operation_mode(args):
     ucat = get_test_categories(alltests)
 
     if args.showID:
-        show_test_case_by_id(alltests, args.showID[0])
+        for atest in alltests:
+            print_test_case(atest)
         exit(0)
 
     if args.execute:
diff --git a/tools/testing/selftests/tc-testing/tdc_helper.py b/tools/testing/selftests/tc-testing/tdc_helper.py
index c3254f861fb2..bca1d3fed4a5 100644
--- a/tools/testing/selftests/tc-testing/tdc_helper.py
+++ b/tools/testing/selftests/tc-testing/tdc_helper.py
@@ -56,20 +56,14 @@ def print_sll(items):
 
 def print_test_case(tcase):
     """ Pretty-printing of a given test case. """
+    print('\n==============\nTest {}\t{}\n'.format(tcase['id'], tcase['name']))
     for k in tcase.keys():
         if (type(tcase[k]) == list):
             print(k + ":")
             print_list(tcase[k])
         else:
-            print(k + ": " + tcase[k])
+            if not ((k == 'id') or (k == 'name')):
+                print(k + ": " + str(tcase[k]))
 
 
-def show_test_case_by_id(testlist, caseID):
-    """ Find the specified test case to pretty-print. """
-    if not any(d.get('id', None) == caseID for d in testlist):
-        print("That ID does not exist.")
-        exit(1)
-    else:
-        print_test_case(next((d for d in testlist if d['id'] == caseID)))
-
 
-- 
2.15.0.rc0
