From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [GIT PULL] sysctl updates for 3.4-rc1
Date: Fri, 23 Mar 2012 16:48:45 -0700
Message-ID: <m14ntevpya.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Linus,

please pull sysctl updates for v3.4-rc1 from:

  git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/sysctl.git master

This tree is against v3.3-rc1 aka dcd6c92267155e70a94b3927bce681ce74b80d1f
The topmost commit is 4e474a00d7ff746ed177ddae14fa8b2d4bad7a00

Highlights:
- Rewrite of sysctl for speed and clarity.

  Insert/remove/Lookup in sysctl are all now O(NlogN) operations, and
  are no longer bottlenecks in the process of adding and removing
  network devices.

  sysctl is now focused on being a filesystem instead of system call
  and the code can all be found in fs/proc/proc_sysctl.c.  Hopefully
  this means the code is now approachable.

  Much thanks is owed to Lucian Grinjincu for keeping at this until
  something was found that was usable.

- The recent proc_sys_poll oops found by the fuzzer during hibernation
  is fixed.

Dan Carpenter (2):
      sysctl: remove an unused variable
      sysctl: fix memset parameters in setup_sysctl_set()

Eric W. Biederman (32):
      sysctl: Consolidate !CONFIG_SYSCTL handling
      sysctl: Register the base sysctl table like any other sysctl table.
      sysctl: Move the implementation into fs/proc/proc_sysctl.c
      sysctl: Make the directories have nlink == 1
      sysctl: Implement retire_sysctl_set
      sysctl: Remove the unnecessary sysctl_set parent concept.
      sysctl: Create local copies of directory names used in paths
      sysctl: Add support for register sysctl tables with a normal cstring path.
      sysctl: Add ctl_table chains into cstring paths
      sysctl: register only tables of sysctl files
      sysctl: Improve the sysctl sanity checks
      sysctl: Remove the now unused ctl_table parent field.
      sysctl: A more obvious version of grab_header.
      sysctl: Initial support for auto-unregistering sysctl tables.
      sysctl: Factor out init_header from __register_sysctl_paths
      sysctl: Factor out insert_header and erase_header
      sysctl: Normalize the root_table data structure.
      sysctl: Rewrite proc_sys_lookup introducing find_entry and lookup_entry.
      sysctl: Rewrite proc_sys_readdir in terms of first_entry and next_entry
      sysctl: Add a root pointer to ctl_table_set
      sysctl: Stop requiring explicit management of sysctl directories
      sysctl: Add sysctl_print_dir and use it in get_subdir
      sysctl: Replace root_list with links between sysctl_table_sets.
      sysctl: Modify __register_sysctl_paths to take a set instead of a root and an nsproxy
      sysctl: Move sysctl_check_dups into insert_header
      sysctl: Make the header lists per directory.
      sysctl: Index sysctl directories with rbtrees.
      sysctl: Add register_sysctl for normal sysctl users
      sysctl: An easier to read version of find_subdir
      sysctl: Correct error return from get_subdir
      sysctl: Comments to make the code clearer.
      sysctl: Don't call sysctl_follow_link unless we are a link.

Lucas De Marchi (2):
      sysctl: remove impossible condition check
      sysctl: protect poll() in entries that may go away

 fs/proc/internal.h     |    3 +
 fs/proc/proc_sysctl.c  | 1274 +++++++++++++++++++++++++++++++++++++++++++++---
 include/linux/sysctl.h |  106 +++--
 kernel/Makefile        |    1 -
 kernel/sysctl.c        |  501 +-------------------
 kernel/sysctl_check.c  |  160 ------
 lib/Kconfig.debug      |    8 -
 net/sysctl_net.c       |   24 +-
 8 files changed, 1280 insertions(+), 797 deletions(-)
