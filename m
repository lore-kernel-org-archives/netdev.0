From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [Review][PATCH][0/29] sysctl rewrite for speed and clarity
Date: Thu, 26 Jan 2012 20:45:20 -0800
Message-ID: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The problem:

   The current implementation of sysctl has data structures and semantics
   that are hard to understand, and causes sysctl to run slowly.
   Sysctl running slowly is a scaling problem in general and the network
   stack in particular.

After some heavy testing and way way too much patch rewriting I believe I
have a patchset that seems sane and reasonable and gets to what looks to
my weary eyes a sane result.

My patchset was heavily inspired by the previous work done by Lucian
Grinjincu.  Lucian kept the need for this work alive, and did a much
better job than I ever though he did.  Unfortunately I missed a lot
of the good things Lucian did my rushed attempts at code review.

This code is also available at:
kernel.org/pub/scm/linux/kernel/git/ebiederm/sysctl.git

Eric W. Biederman (28):
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

Lucas De Marchi (1):
      sysctl: remove impossible condition check

 fs/proc/internal.h     |    3 +
 fs/proc/proc_sysctl.c  | 1240 +++++++++++++++++++++++++++++++++++++++++++++---
 include/linux/sysctl.h |  106 +++--
 kernel/Makefile        |    1 -
 kernel/sysctl.c        |  501 +-------------------
 kernel/sysctl_check.c  |  160 -------
 lib/Kconfig.debug      |    8 -
 net/sysctl_net.c       |   24 +-
 8 files changed, 1247 insertions(+), 796 deletions(-)


Eric
