From: Richard Haines <richard_c_haines@btinternet.com>
Subject: [RFC PATCH 0/5] Add SELinux SCTP protocol support
Date: Tue, 17 Oct 2017 14:53:59 +0100
Message-ID: <20171017135359.4010-1-richard_c_haines@btinternet.com>
Cc: paul@paul-moore.com, vyasevich@gmail.com, nhorman@tuxdriver.com,
        sds@tycho.nsa.gov, eparis@parisplace.org,
        marcelo.leitner@gmail.com,
        Richard Haines <richard_c_haines@btinternet.com>
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set adds SELinux support to SCTP and incorporates all the
comments received from my previous attemps (thanks to all who responded).
There are also other changes mainly supporting ip options so that CIPSO
and CALIPSO work over SCTP.

The kernel patches have been built on Fedora 26 with kernel 4.13.4 plus the
following userspace patches to enable testing:

1) Updates to libsepol 2.7 to support the sctp portcon statement.
   The patch is available from:
         http://arctic.selinuxproject.org/~rhaines/selinux-sctp/
         selinux-Add-support-for-the-SCTP-portcon-keyword.patch

2) Updates to the SELinux Test Suite adding SCTP tests. Please read the
   selinux-testsuite/README.sctp for details. The patch is available from:
         http://arctic.selinuxproject.org/~rhaines/selinux-sctp/
         selinux-testsuite-Add-SCTP-test-support.patch

3) Updates to lksctp-tools that show SELinux info in sctp_darn and
   sctp_test. It also contains a minor patch for test_1_to_1_connect.c
   as when CIPSO/CALIPSO configured, NetLabel returns a different error
   code for illegal addresses in test 5. The patch is available from:
         http://arctic.selinuxproject.org/~rhaines/selinux-sctp/
         lksctp-tools-Add-SELinux-support-to-sctp_test-and-sc.patch

All SCTP lksctp-tools/src/func_tests run correctly in enforcing mode.

All SCTP regression tests "./sctp-tests run" run correctly in enforcing
mode. These tests are obtained from: https://github.com/sctp/sctp-tests

The selinux-testsuite patch also adds remote tests (that need some manual
configuration). These are useful for testing CIPSO/CALIPSO over a network
with a number of categories to produce large ip option fields with various
message sizes forcing fragmentation etc..


Richard Haines (5):
  security: Add support for SCTP security hooks
  sctp: Add ip option support
  sctp: Add LSM hooks
  netlabel: Add SCTP support
  selinux: Add SCTP support

 Documentation/security/LSM-sctp.txt     | 212 +++++++++++++++++++++++++
 Documentation/security/SELinux-sctp.txt | 108 +++++++++++++
 include/linux/lsm_hooks.h               |  37 +++++
 include/linux/security.h                |  27 ++++
 include/net/netlabel.h                  |   3 +
 include/net/sctp/structs.h              |  12 ++
 include/uapi/linux/sctp.h               |   1 +
 net/netlabel/netlabel_kapi.c            |  80 ++++++++++
 net/netlabel/netlabel_unlabeled.c       |  10 ++
 net/sctp/chunk.c                        |   7 +-
 net/sctp/ipv6.c                         |  37 ++++-
 net/sctp/output.c                       |   3 +-
 net/sctp/protocol.c                     |  36 +++++
 net/sctp/sm_make_chunk.c                |  12 ++
 net/sctp/sm_statefuns.c                 |  14 +-
 net/sctp/socket.c                       |  66 +++++++-
 security/security.c                     |  23 +++
 security/selinux/hooks.c                | 268 ++++++++++++++++++++++++++++++--
 security/selinux/include/classmap.h     |   3 +-
 security/selinux/include/netlabel.h     |   9 +-
 security/selinux/include/objsec.h       |   5 +
 security/selinux/netlabel.c             |  52 ++++++-
 22 files changed, 993 insertions(+), 32 deletions(-)
 create mode 100644 Documentation/security/LSM-sctp.txt
 create mode 100644 Documentation/security/SELinux-sctp.txt

-- 
2.13.6

