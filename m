From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/5] BPF/random32 updates
Date: Wed,  7 Oct 2015 15:43:51 +0200
Message-ID: <cover.1444224502.git.daniel@iogearbox.net>
Cc: hannes@stressinduktion.org, ast@plumgrid.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45108 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbbJGNoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 09:44:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BPF update to split the prandom state apart, and to move the
*once helpers to the core. For details, please see individual
patches. Given the changes and since it's in the tree for
quite some time, net-next is a better choice in our opinion.

Thanks!

Daniel Borkmann (3):
  random32: add prandom_seed_full_state helper
  random32: add prandom_init_once helper for own rngs
  bpf: split state from prandom_u32() and consolidate {c,e}BPF prngs

Hannes Frederic Sowa (2):
  net: move net_get_random_once to lib
  once: make helper generic for calling function once

 include/linux/bpf.h    |  4 ++++
 include/linux/net.h    | 21 ++++-------------
 include/linux/once.h   | 35 ++++++++++++++++++++++++++++
 include/linux/random.h |  6 +++++
 kernel/bpf/core.c      | 26 +++++++++++++++++++++
 kernel/bpf/helpers.c   |  7 +-----
 kernel/bpf/syscall.c   |  2 ++
 lib/Makefile           |  3 ++-
 lib/once.c             | 62 ++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/random32.c         | 42 +++++++++++++++++++++-------------
 net/core/filter.c      |  9 ++------
 net/core/utils.c       | 49 ---------------------------------------
 12 files changed, 170 insertions(+), 96 deletions(-)
 create mode 100644 include/linux/once.h
 create mode 100644 lib/once.c

-- 
1.9.3
