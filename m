From: "Brenda J. Butler" <bjb@mojatatu.com>
Subject: [PATCH net-next] tc-testing: split config file
Date: Tue, 31 Oct 2017 14:27:28 -0400
Message-ID: <20171031182728.9725-1-bjb@mojatatu.com>
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        chrism@mellanox.com, lucasb@mojatatu.com, aring@mojatatu.com,
        mrv@mojatatu.com, netdev@vger.kernel.org,
        "Brenda J. Butler" <bjb@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:50213 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932628AbdJaS1f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:27:35 -0400
Received: by mail-io0-f179.google.com with SMTP id 97so829068iok.7
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:27:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the config customization into a site-local file
tdc_config_local.py, so that updates of the tdc test
software does not require hand-editing of the config.
This patch includes a template for the site-local
customization file.

In addition, this makes it easy to revert to a stock
tdc environment for testing the test framework and/or
the core tests.

Also it makes it harder for any custom config to be
submitted back to the kernel tdc.

Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
---
 tools/testing/selftests/tc-testing/tdc_config.py   | 14 +++++++++++++
 .../tc-testing/tdc_config_local_template.py        | 24 ++++++++++++++++++++++
 2 files changed, 38 insertions(+)
 create mode 100644 tools/testing/selftests/tc-testing/tdc_config_local_template.py

diff --git a/tools/testing/selftests/tc-testing/tdc_config.py b/tools/testing/selftests/tc-testing/tdc_config.py
index b6352515c1b5..596558445713 100644
--- a/tools/testing/selftests/tc-testing/tdc_config.py
+++ b/tools/testing/selftests/tc-testing/tdc_config.py
@@ -17,3 +17,17 @@ NAMES = {
           # Name of the namespace to use
           'NS': 'tcut'
         }
+
+
+ENVIR = { }
+
+# put customizations in tdc_config_local.py
+try:
+    from tdc_config_local import *
+except ImportError as ie:
+    pass
+
+try:
+    NAMES.update(EXTRA_NAMES)
+except NameError as ne:
+    pass
diff --git a/tools/testing/selftests/tc-testing/tdc_config_local_template.py b/tools/testing/selftests/tc-testing/tdc_config_local_template.py
new file mode 100644
index 000000000000..24bad1633cac
--- /dev/null
+++ b/tools/testing/selftests/tc-testing/tdc_config_local_template.py
@@ -0,0 +1,24 @@
+"""
+tdc_config_local.py - tdc plugin-writer-specified values
+
+Copyright (C) 2017 bjb@mojatatu.com
+"""
+
+import os
+
+ENVIR = os.environ.copy()
+
+ENV_LD_LIBRARY_PATH = os.getenv('LD_LIBRARY_PATH', '')
+ENV_OTHER_LIB = os.getenv('OTHER_LIB', '')
+
+
+# example adding value to NAMES, without editing tdc_config.py
+EXTRA_NAMES = dict()
+EXTRA_NAMES['SOME_BIN'] = os.path.join(os.getenv('OTHER_BIN', ''), 'some_bin')
+
+
+# example adding values to ENVIR, without editing tdc_config.py
+ENVIR['VALGRIND_LIB'] = '/usr/lib/valgrind'
+ENVIR['VALGRIND_BIN'] = '/usr/bin/valgrind'
+ENVIR['VGDB_BIN'] = '/usr/bin/vgdb'
+
-- 
2.15.0.rc0
