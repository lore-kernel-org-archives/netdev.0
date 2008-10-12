From: James Morris <jmorris@namei.org>
Subject: [GIT] Security related updates
Date: Mon, 13 Oct 2008 10:16:48 +1100 (EST)
Message-ID: <alpine.LRH.1.10.0810131013580.16409@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Linus,

Some more security-related updates for 2.6.28, notably including an update 
to Paul Moore's Netlabel code (DaveM asked for it to go via my tree, and 
it is self-contained) and TPM updates.  Please pull.

The following changes since commit f1b2a5ace996de339292d4035f9f5b294aecd11e:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../sfrench/cifs-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/security-testing-2.6 for-linus

Andrew Morton (1):
      ERROR: code indent should use tabs where possible

James Morris (2):
      Merge branch 'master' of git://git.infradead.org/users/pcmoore/lblnet-2.6_next into next
      Merge branch 'next' into for-linus

Mimi Zohar (1):
      integrity: special fs magic

Paul Moore (17):
      netlabel: Fix some sparse warnings
      selinux: Cleanup the NetLabel glue code
      selinux: Correctly handle IPv4 packets on IPv6 sockets in all cases
      netlabel: Remove unneeded in-kernel API functions
      selinux: Better local/forward check in selinux_ip_postroute()
      selinux: Fix a problem in security_netlbl_sid_to_secattr()
      selinux: Fix missing calls to netlbl_skbuff_err()
      smack: Fix missing calls to netlbl_skbuff_err()
      netlabel: Replace protocol/NetLabel linking with refrerence counts
      netlabel: Add a generic way to create ordered linked lists of network addrs
      netlabel: Add network address selectors to the NetLabel/LSM domain mapping
      netlabel: Add functionality to set the security attributes of a packet
      selinux: Set socket NetLabel based on connection endpoint
      selinux: Cache NetLabel secattrs in the socket's security struct
      netlabel: Changes to the NetLabel security attributes to allow LSMs to pass full contexts
      cipso: Add support for native local labeling and fixup mapping names
      netlabel: Add configuration support for local labeling

Rajiv Andrade (5):
      Remove the BKL calls from the TPM driver, which were added in the overall
      Renames num_open to is_open, as only one process can open the file at a time.
      Protect tpm_chip_list when transversing it.
      The tpm_dev_release function is only called for platform devices, not pnp
      As pointed out by Jonathan Corbet, the timer must be deleted before

 drivers/char/tpm/tpm.c              |   96 +++---
 drivers/char/tpm/tpm.h              |    3 +-
 drivers/char/tpm/tpm_tis.c          |   14 +-
 fs/debugfs/inode.c                  |    3 +-
 include/linux/magic.h               |    4 +
 include/net/cipso_ipv4.h            |   55 +++-
 include/net/netlabel.h              |   51 ++-
 mm/shmem.c                          |    4 +-
 net/ipv4/cipso_ipv4.c               |  656 ++++++++++++++++++++++++-----------
 net/ipv4/ip_options.c               |    2 +-
 net/netlabel/Makefile               |    3 +-
 net/netlabel/netlabel_addrlist.c    |  388 +++++++++++++++++++++
 net/netlabel/netlabel_addrlist.h    |  189 ++++++++++
 net/netlabel/netlabel_cipso_v4.c    |  136 +++++---
 net/netlabel/netlabel_cipso_v4.h    |   10 +-
 net/netlabel/netlabel_domainhash.c  |  393 ++++++++++++++++-----
 net/netlabel/netlabel_domainhash.h  |   40 ++-
 net/netlabel/netlabel_kapi.c        |  272 ++++++++++-----
 net/netlabel/netlabel_mgmt.c        |  410 ++++++++++++++++------
 net/netlabel/netlabel_mgmt.h        |   59 +++-
 net/netlabel/netlabel_unlabeled.c   |  456 ++++++++----------------
 security/inode.c                    |    3 +-
 security/selinux/hooks.c            |  229 +++++++++----
 security/selinux/include/netlabel.h |   44 +++-
 security/selinux/include/objsec.h   |    9 +-
 security/selinux/netlabel.c         |  280 +++++++++++++---
 security/selinux/ss/services.c      |   13 +-
 security/smack/smack_lsm.c          |    5 +-
 security/smack/smackfs.c            |    4 +-
 29 files changed, 2800 insertions(+), 1031 deletions(-)
 create mode 100644 net/netlabel/netlabel_addrlist.c
 create mode 100644 net/netlabel/netlabel_addrlist.h


-- 
James Morris
<jmorris@namei.org>
