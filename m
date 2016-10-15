From: Julia Lawall <julia.lawall@lip6.fr>
Subject: [net:master 10/15] net/ipv6/addrconf.c:1251:14-30: WARNING: Unsigned
 expression compared with zero: tmp_prefered_lft < 0
Date: Sat, 15 Oct 2016 19:46:41 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1610151945380.9280@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, kbuild-all@01.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:52492 "EHLO
        mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753128AbcJORuA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 13:50:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I haven't checked the entire context, but it could be useful to look at
line 1251.

julia

---------- Forwarded message ----------
Date: Sun, 16 Oct 2016 01:34:18 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: [net:master 10/15] net/ipv6/addrconf.c:1251:14-30: WARNING: Unsigned
    expression compared with zero: tmp_prefered_lft < 0

CC: kbuild-all@01.org
CC: netdev@vger.kernel.org
TO: Jiri Bohac <jbohac@suse.cz>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
head:   9e55d0f95460a067def5400fa5eee5dabb0fc5a5
commit: 76506a986dc31394fd1f2741db037d29c7e57843 [10/15] IPv6: fix DESYNC_FACTOR
:::::: branch date: 21 hours ago
:::::: commit date: 27 hours ago

>> net/ipv6/addrconf.c:1251:14-30: WARNING: Unsigned expression compared with zero: tmp_prefered_lft < 0

git remote add net https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
git remote update net
git checkout 76506a986dc31394fd1f2741db037d29c7e57843
vim +1251 net/ipv6/addrconf.c

76506a986 Jiri Bohac     2016-10-13  1235  	if (unlikely(idev->desync_factor > max_desync_factor)) {
76506a986 Jiri Bohac     2016-10-13  1236  		if (max_desync_factor > 0) {
76506a986 Jiri Bohac     2016-10-13  1237  			get_random_bytes(&idev->desync_factor,
76506a986 Jiri Bohac     2016-10-13  1238  					 sizeof(idev->desync_factor));
76506a986 Jiri Bohac     2016-10-13  1239  			idev->desync_factor %= max_desync_factor;
76506a986 Jiri Bohac     2016-10-13  1240  		} else {
76506a986 Jiri Bohac     2016-10-13  1241  			idev->desync_factor = 0;
76506a986 Jiri Bohac     2016-10-13  1242  		}
76506a986 Jiri Bohac     2016-10-13  1243  	}
76506a986 Jiri Bohac     2016-10-13  1244
^1da177e4 Linus Torvalds 2005-04-16  1245  	tmp_valid_lft = min_t(__u32,
^1da177e4 Linus Torvalds 2005-04-16  1246  			      ifp->valid_lft,
7a876b0ef Glenn Wurster  2010-09-27  1247  			      idev->cnf.temp_valid_lft + age);
76506a986 Jiri Bohac     2016-10-13  1248  	tmp_prefered_lft = idev->cnf.temp_prefered_lft + age -
76506a986 Jiri Bohac     2016-10-13  1249  			    idev->desync_factor;
76506a986 Jiri Bohac     2016-10-13  1250  	/* guard against underflow in case of concurrent updates to cnf */
76506a986 Jiri Bohac     2016-10-13 @1251  	if (unlikely(tmp_prefered_lft < 0))
76506a986 Jiri Bohac     2016-10-13  1252  		tmp_prefered_lft = 0;
76506a986 Jiri Bohac     2016-10-13  1253  	tmp_prefered_lft = min_t(__u32, ifp->prefered_lft, tmp_prefered_lft);
^1da177e4 Linus Torvalds 2005-04-16  1254  	tmp_plen = ifp->prefix_len;
^1da177e4 Linus Torvalds 2005-04-16  1255  	tmp_tstamp = ifp->tstamp;
^1da177e4 Linus Torvalds 2005-04-16  1256  	spin_unlock_bh(&ifp->lock);
^1da177e4 Linus Torvalds 2005-04-16  1257
53bd67491 Jiri Pirko     2013-12-06  1258  	write_unlock_bh(&idev->lock);
95c385b4d Neil Horman    2007-04-25  1259

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
