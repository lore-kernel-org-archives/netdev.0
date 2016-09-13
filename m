From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v2 0/6] Move runnable code (tests) from Documentation to selftests
Date: Tue, 13 Sep 2016 14:18:39 -0600
Message-ID: <cover.1473795601.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-watchdog@vger.kernel.org, linux-kselftest@vger.kernel.org
To: corbet@lwn.net, richardcochran@gmail.com, wim@iguana.be,
        linux@roeck-us.net, nab@linux-iscsi.org,
        maheshkhanwalkar@gmail.com, timur@codeaurora.org, arnd@arndb.de,
        ghackmann@google.com, ben@decadent.org.uk, thuth@redhat.com,
        christopher.s.hall@intel.com, john.stultz@linaro.org,
        sergei.shtylyov@cogentembedded.com, mpe@ellerman.id.au,
        jani.nikula@linux.intel.com
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

Changes since v1:
- Changes to Documentation/Makefile to remove test targets as the tests
  get moved.
- Combined patches based on Michael Ellerman's comments.
- Fixed change log errors based on Sergei Shtylyov's comments.
- Expanded to list to wider audience and people that responded
  with comments and ideas.
- Included ia64 and watchdog which I missed in the v1 series.

Shuah Khan (6):
  selftests: move dnotify_test from Documentation/filesystems
  selftests: move prctl tests from Documentation/prctl
  selftests: move ptp tests from Documentation/ptp
  selftests: move vDSO tests from Documentation/vDSO
  selftests: move ia64 tests from Documentation/ia64
  selftests: move watchdog tests from Documentation/watchdog

 Documentation/Makefile                             |   4 +-
 Documentation/filesystems/.gitignore               |   1 -
 Documentation/filesystems/Makefile                 |   5 -
 Documentation/filesystems/dnotify_test.c           |  34 --
 Documentation/ia64/.gitignore                      |   1 -
 Documentation/ia64/Makefile                        |   5 -
 Documentation/ia64/aliasing-test.c                 | 263 -----------
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
 Documentation/watchdog/src/.gitignore              |   1 -
 Documentation/watchdog/src/Makefile                |   2 +-
 Documentation/watchdog/src/watchdog-test.c         | 105 -----
 tools/testing/selftests/filesystems/.gitignore     |   1 +
 tools/testing/selftests/filesystems/Makefile       |   7 +
 tools/testing/selftests/filesystems/dnotify_test.c |  34 ++
 tools/testing/selftests/ia64/.gitignore            |   1 +
 tools/testing/selftests/ia64/Makefile              |   8 +
 tools/testing/selftests/ia64/aliasing-test.c       | 263 +++++++++++
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
 tools/testing/selftests/watchdog/.gitignore        |   1 +
 tools/testing/selftests/watchdog/Makefile          |   8 +
 tools/testing/selftests/watchdog/watchdog-test.c   | 105 +++++
 47 files changed, 1773 insertions(+), 1752 deletions(-)
 delete mode 100644 Documentation/filesystems/.gitignore
 delete mode 100644 Documentation/filesystems/Makefile
 delete mode 100644 Documentation/filesystems/dnotify_test.c
 delete mode 100644 Documentation/ia64/.gitignore
 delete mode 100644 Documentation/ia64/Makefile
 delete mode 100644 Documentation/ia64/aliasing-test.c
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
 delete mode 100644 Documentation/watchdog/src/watchdog-test.c
 create mode 100644 tools/testing/selftests/filesystems/.gitignore
 create mode 100644 tools/testing/selftests/filesystems/Makefile
 create mode 100644 tools/testing/selftests/filesystems/dnotify_test.c
 create mode 100644 tools/testing/selftests/ia64/.gitignore
 create mode 100644 tools/testing/selftests/ia64/Makefile
 create mode 100644 tools/testing/selftests/ia64/aliasing-test.c
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
 create mode 100644 tools/testing/selftests/watchdog/.gitignore
 create mode 100644 tools/testing/selftests/watchdog/Makefile
 create mode 100644 tools/testing/selftests/watchdog/watchdog-test.c

-- 
2.7.4
