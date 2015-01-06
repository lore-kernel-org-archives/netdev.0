From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v4 00/20] kselftest install target feature
Date: Tue,  6 Jan 2015 12:43:14 -0700
Message-ID: <cover.1420571615.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: mmarek@suse.cz, gregkh@linuxfoundation.org,
	akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com,
	davem@davemloft.net, keescook@chromium.org, tranmanphong@gmail.com,
	mpe@ellerman.id.au, cov@codeaurora.org, dh.herrmann@gmail.com,
	hughd@google.com, bobby.prani@gmail.com, serge.hallyn@ubuntu.com,
	ebiederm@xmission.com, tim.bird@sonymobile.com,
	josh@joshtriplett.org, koct9i@gmail.com,
	masami.hiramatsu.pt@hitachi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-ch2-04v.sys.comcast.net ([69.252.207.36]:51986 "EHLO
	resqmta-ch2-04v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932667AbbAFTwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:52:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds a new kselftest_install make target
to enable selftest install. When make kselftest_install is
run, selftests are installed on the system. A new install
target is added to selftests Makefile which will install
targets for the tests that are specified in INSTALL_TARGETS.
During install, a script is generated to run tests that are
installed. This script will be installed in the selftest install
directory. Individual test Makefiles are changed to add to the
script. This will allow new tests to add install and run test
commands to the generated kselftest script. kselftest target
now depends on kselftest_install and runs the generated kselftest
script to reduce duplicate work and for common look and feel when
running tests.

This approach leverages and extends the existing framework that
uses makefile targets to implement run_tests and adds install
target. This will scale well as new tests get added and makes
it easier for test writers to add install target at the same
time new test gets added.

This series is uploaded to the following experimental branch
for anybody that is interested in playing with it:
git://git.kernel.org/pub/scm/linux/kernel/git/shuah/linux-kselftest.git devel

Some benchmark numbers: no relation to this patch series,
I just happened to get some timing numbers, this is nice
and low.
kselftest full run from install dir using kselftest.sh
9.41user 3.55system 0:24.86elapsed

This v4 series fixes echo strings to add quotes around them.
There is no change to the 00/20 kbuild patch in this series.
Other patches in the sries are updated to fix the echo strings.

v3 series: reduced duplicate code to generate script
in indiviual test Makefiles and consolidates support in
selftests main Makefile. In the main Makefile, it does
minimal work to set and export install path.

v2 series: addressed the duplicate code in install and
run_tests targets in individual test Makefiles.
Reference: https://lkml.org/lkml/2014/11/4/707

Shuah Khan (20):
  selftests/breakpoints: add install target to enable test install
  selftests/cpu-hotplug: add install target to enable test install
  selftests/efivarfs: add install target to enable test install
  selftests/firmware: add install target to enable test install
  selftests/ftrace: add install target to enable test install
  selftests/ipc: add install target to enable test install
  selftests/kcmp: add install target to enable test install
  selftests/memfd: add install target to enable test install
  selftests/memory-hotplug: add install target to enable test install
  selftests/mount: add install target to enable test install
  selftests/mqueue: add install target to enable test install
  selftests/net: add install target to enable test install
  selftests/ptrace: add install target to enable test install
  selftests/size: add install target to enable test install
  selftests/sysctl: add install target to enable test install
  selftests/timers: add install target to enable test install
  selftests/user: add install target to enable test install
  selftests/vm: add install target to enable test install
  selftests: add install target to enable test install
  kbuild: add a new kselftest_install make target to install selftests

 Makefile                                           | 14 +++++-
 tools/testing/selftests/Makefile                   | 54 +++++++++++++++++++++-
 tools/testing/selftests/breakpoints/Makefile       | 19 +++++++-
 tools/testing/selftests/cpu-hotplug/Makefile       | 14 +++++-
 .../{on-off-test.sh => cpu-on-off-test.sh}         |  0
 tools/testing/selftests/efivarfs/Makefile          | 16 ++++++-
 tools/testing/selftests/firmware/Makefile          | 43 ++++++++++-------
 tools/testing/selftests/ftrace/Makefile            | 13 +++++-
 tools/testing/selftests/ipc/Makefile               | 19 +++++++-
 tools/testing/selftests/kcmp/Makefile              | 13 +++++-
 tools/testing/selftests/memfd/Makefile             | 17 +++++--
 tools/testing/selftests/memory-hotplug/Makefile    | 14 +++++-
 .../{on-off-test.sh => mem-on-off-test.sh}         |  0
 tools/testing/selftests/mount/Makefile             | 12 ++++-
 tools/testing/selftests/mqueue/Makefile            | 18 ++++++--
 tools/testing/selftests/net/Makefile               | 20 ++++++--
 tools/testing/selftests/ptrace/Makefile            | 16 +++++--
 tools/testing/selftests/size/Makefile              | 12 ++++-
 tools/testing/selftests/sysctl/Makefile            | 17 ++++++-
 tools/testing/selftests/timers/Makefile            | 12 ++++-
 tools/testing/selftests/user/Makefile              | 12 ++++-
 tools/testing/selftests/vm/Makefile                | 11 ++++-
 22 files changed, 317 insertions(+), 49 deletions(-)
 rename tools/testing/selftests/cpu-hotplug/{on-off-test.sh => cpu-on-off-test.sh} (100%)
 rename tools/testing/selftests/memory-hotplug/{on-off-test.sh => mem-on-off-test.sh} (100%)

-- 
2.1.0
