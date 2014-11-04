From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 00/20] kselftest install target feature
Date: Tue,  4 Nov 2014 10:10:56 -0700
Message-ID: <cover.1415117102.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mmarek@suse.cz, davem@davemloft.net, keescook@chromium.org,
	tranmanphong@gmail.com, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, ebiederm@xmission.com,
	serge.hallyn@ubuntu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series adds a new kselftest_install make target
to enable selftest install. When make kselftest_install is
run, selftests are installed on the system. A new install
target is added to selftests Makefile which will install
targets for the tests that are specified in INSTALL_TARGETS.
During install, a script is generated to run tests that are
installed. This script will be installed in the selftest install
directory. Individual test Makefiles are changed to add to the
script. This will allow new tests to add install and run test
commands to the generated kselftest script.

Approach:

make kselftest_target:
-- exports kselftest INSTALL_KSFT_PATH
   default $(INSTALL_MOD_PATH)/lib/kselftest/$(KERNELRELEASE)
-- exports path for ksefltest.sh
-- runs selftests make install target:

selftests make install target
-- creates kselftest.sh script in install install dir
-- runs install targets for all INSTALL_TARGETS

Individual test make install targets:
-- install test programs and/or scripts in install dir
-- append to the ksefltest.sh file to add commands to run test

Shuah Khan (20):
  selftests/user: move test out of Makefile into a shell script
  selftests/net: move test out of Makefile into a shell script
  kbuild: kselftest_install - add a new make target to install selftests
  selftests: add install target to enable installing selftests
  selftests/breakpoints: add install target to enable installing test
  selftests/cpu-hotplug: add install target to enable installing test
  selftests/efivarfs: add install target to enable installing test
  selftests/firmware: add install target to enable installing test
  selftests/ipc: add install target to enable installing test
  selftests/kcmp: add install target to enable installing test
  selftests/memfd: add install target to enable installing test
  selftests/memory-hotplug: add install target to enable installing test
  selftests/mount: add install target to enable installing test
  selftests/mqueue: add install target to enable installing test
  selftests/net: add install target to enable installing test
  selftests/ptrace: add install target to enable installing test
  selftests/sysctl: add install target to enable installing test
  selftests/timers: add install target to enable installing test
  selftests/vm: add install target to enable installing test
  selftests/user: add install target to enable installing test

 Makefile                                        | 17 +++++++++++++++++
 tools/testing/selftests/Makefile                | 14 ++++++++++++++
 tools/testing/selftests/breakpoints/Makefile    | 12 ++++++++++++
 tools/testing/selftests/cpu-hotplug/Makefile    |  9 +++++++++
 tools/testing/selftests/efivarfs/Makefile       | 13 ++++++++++++-
 tools/testing/selftests/firmware/Makefile       | 20 ++++++++++++++++++++
 tools/testing/selftests/ipc/Makefile            | 11 +++++++++++
 tools/testing/selftests/kcmp/Makefile           | 12 ++++++++++++
 tools/testing/selftests/memfd/Makefile          | 10 ++++++++++
 tools/testing/selftests/memory-hotplug/Makefile |  9 +++++++++
 tools/testing/selftests/mount/Makefile          |  7 +++++++
 tools/testing/selftests/mqueue/Makefile         |  8 ++++++++
 tools/testing/selftests/net/Makefile            | 18 +++++++++++-------
 tools/testing/selftests/net/test_bpf.sh         | 10 ++++++++++
 tools/testing/selftests/ptrace/Makefile         | 11 +++++++++--
 tools/testing/selftests/sysctl/Makefile         | 10 ++++++++++
 tools/testing/selftests/timers/Makefile         |  7 +++++++
 tools/testing/selftests/user/Makefile           | 15 ++++++++-------
 tools/testing/selftests/user/test_user_copy.sh  | 10 ++++++++++
 tools/testing/selftests/vm/Makefile             |  7 +++++++
 20 files changed, 213 insertions(+), 17 deletions(-)
 create mode 100755 tools/testing/selftests/net/test_bpf.sh
 create mode 100755 tools/testing/selftests/user/test_user_copy.sh

-- 
1.9.1
