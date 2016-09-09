From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 0/9] Move runnable code (tests) from Documentation to selftests
Date: Fri,  9 Sep 2016 16:22:41 -0600
Message-ID: <cover.1473458697.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: corbet@lwn.net, richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move runnable code (tests) from Documentation to selftests and update
Makefiles to work under selftests.

Jon Corbet and I discussed this in an email thread and as per that
discussion, this patch series moves all the tests that are under the
Documentation directory to selftests. There is more runnable code in
the form of examples and utils and that is going to be another patch
series. I moved just the tests and left the documentation files as is.

Checkpatch isn't happy with a few of the patches as some of the
renamed files have existing checkpatch errors and warnings. I am
working another patch series that will address those.

Shuah Khan (9):
  selftests: move dnotify_test from Documentation/filesystems
  selftests: update filesystems Makefile to work under selftests
  selftests: move .gitignore from Documentation/filesystems
  selftests: move prctl tests from Documentation/prctl
  selftests: Update prctl Makefile to work under selftests
  selftests: move ptp tests from Documentation/ptp
  selftests: Update ptp Makefile to work under selftests
  selftests: move vDSO tests from Documentation/vDSO
  selftests: Update vDSO Makefile to work under selftests

 Documentation/filesystems/.gitignore               |   1 -
 Documentation/filesystems/Makefile                 |   5 -
 Documentation/filesystems/dnotify_test.c           |  34 --
 Documentation/prctl/.gitignore                     |   3 -
 Documentation/prctl/Makefile                       |  10 -
 .../prctl/disable-tsc-ctxt-sw-stress-test.c        |  97 ----
 .../prctl/disable-tsc-on-off-stress-test.c         |  96 ----
 Documentation/prctl/disable-tsc-test.c             |  95 ----
 Documentation/ptp/.gitignore                       |   1 -
 Documentation/ptp/Makefile                         |   8 -
 Documentation/ptp/testptp.c                        | 523 ---------------------
 Documentation/ptp/testptp.mk                       |  33 --
 Documentation/vDSO/.gitignore                      |   2 -
 Documentation/vDSO/Makefile                        |  17 -
 Documentation/vDSO/parse_vdso.c                    | 269 -----------
 Documentation/vDSO/vdso_standalone_test_x86.c      | 128 -----
 Documentation/vDSO/vdso_test.c                     |  52 --
 tools/testing/selftests/filesystems/.gitignore     |   1 +
 tools/testing/selftests/filesystems/Makefile       |   7 +
 tools/testing/selftests/filesystems/dnotify_test.c |  34 ++
 tools/testing/selftests/prctl/.gitignore           |   3 +
 tools/testing/selftests/prctl/Makefile             |  15 +
 .../prctl/disable-tsc-ctxt-sw-stress-test.c        |  97 ++++
 .../prctl/disable-tsc-on-off-stress-test.c         |  96 ++++
 tools/testing/selftests/prctl/disable-tsc-test.c   |  95 ++++
 tools/testing/selftests/ptp/.gitignore             |   1 +
 tools/testing/selftests/ptp/Makefile               |   8 +
 tools/testing/selftests/ptp/testptp.c              | 523 +++++++++++++++++++++
 tools/testing/selftests/ptp/testptp.mk             |  33 ++
 tools/testing/selftests/vDSO/.gitignore            |   2 +
 tools/testing/selftests/vDSO/Makefile              |  20 +
 tools/testing/selftests/vDSO/parse_vdso.c          | 269 +++++++++++
 .../selftests/vDSO/vdso_standalone_test_x86.c      | 128 +++++
 tools/testing/selftests/vDSO/vdso_test.c           |  52 ++
 34 files changed, 1384 insertions(+), 1374 deletions(-)
 delete mode 100644 Documentation/filesystems/.gitignore
 delete mode 100644 Documentation/filesystems/Makefile
 delete mode 100644 Documentation/filesystems/dnotify_test.c
 delete mode 100644 Documentation/prctl/.gitignore
 delete mode 100644 Documentation/prctl/Makefile
 delete mode 100644 Documentation/prctl/disable-tsc-ctxt-sw-stress-test.c
 delete mode 100644 Documentation/prctl/disable-tsc-on-off-stress-test.c
 delete mode 100644 Documentation/prctl/disable-tsc-test.c
 delete mode 100644 Documentation/ptp/.gitignore
 delete mode 100644 Documentation/ptp/Makefile
 delete mode 100644 Documentation/ptp/testptp.c
 delete mode 100644 Documentation/ptp/testptp.mk
 delete mode 100644 Documentation/vDSO/.gitignore
 delete mode 100644 Documentation/vDSO/Makefile
 delete mode 100644 Documentation/vDSO/parse_vdso.c
 delete mode 100644 Documentation/vDSO/vdso_standalone_test_x86.c
 delete mode 100644 Documentation/vDSO/vdso_test.c
 create mode 100644 tools/testing/selftests/filesystems/.gitignore
 create mode 100644 tools/testing/selftests/filesystems/Makefile
 create mode 100644 tools/testing/selftests/filesystems/dnotify_test.c
 create mode 100644 tools/testing/selftests/prctl/.gitignore
 create mode 100644 tools/testing/selftests/prctl/Makefile
 create mode 100644 tools/testing/selftests/prctl/disable-tsc-ctxt-sw-stress-test.c
 create mode 100644 tools/testing/selftests/prctl/disable-tsc-on-off-stress-test.c
 create mode 100644 tools/testing/selftests/prctl/disable-tsc-test.c
 create mode 100644 tools/testing/selftests/ptp/.gitignore
 create mode 100644 tools/testing/selftests/ptp/Makefile
 create mode 100644 tools/testing/selftests/ptp/testptp.c
 create mode 100644 tools/testing/selftests/ptp/testptp.mk
 create mode 100644 tools/testing/selftests/vDSO/.gitignore
 create mode 100644 tools/testing/selftests/vDSO/Makefile
 create mode 100644 tools/testing/selftests/vDSO/parse_vdso.c
 create mode 100644 tools/testing/selftests/vDSO/vdso_standalone_test_x86.c
 create mode 100644 tools/testing/selftests/vDSO/vdso_test.c

-- 
2.7.4
