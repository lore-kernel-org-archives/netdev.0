From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 194/208] include/net/sock.h:1363:13: error:
 'lockdep_sock_is_held' defined but not used
Date: Fri, 8 Apr 2016 05:34:28 +0800
Message-ID: <201604080525.GUAYfEjK%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="4Ckj6UjgE2iN1+kY"
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:63764 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752883AbcDGVft (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 17:35:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   889750bd2e08a94d52a116056d462b3a8e5616a7
commit: 1e1d04e678cf72442f57ce82803c7a407769135f [194/208] net: introduce lockdep_is_held and update various places to use it
config: sparc64-allnoconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 1e1d04e678cf72442f57ce82803c7a407769135f
        # save the attached .config to linux build tree
        make.cross ARCH=sparc64 

All errors (new ones prefixed by >>):

   In file included from include/linux/tcp.h:22:0,
                    from include/linux/ipv6.h:75,
                    from include/net/ipv6.h:16,
                    from include/linux/sunrpc/clnt.h:27,
                    from include/linux/nfs_fs.h:30,
                    from arch/sparc/kernel/sys_sparc32.c:24:
   include/net/sock.h: In function 'lockdep_sock_is_held':
   include/net/sock.h:1367:2: error: implicit declaration of function 'lockdep_is_held' [-Werror=implicit-function-declaration]
     return lockdep_is_held(&sk->sk_lock) ||
     ^
   arch/sparc/kernel/sys_sparc32.c: At top level:
>> include/net/sock.h:1363:13: error: 'lockdep_sock_is_held' defined but not used [-Werror=unused-function]
    static bool lockdep_sock_is_held(const struct sock *csk)
                ^
   cc1: all warnings being treated as errors

vim +/lockdep_sock_is_held +1363 include/net/sock.h

  1357				sizeof((sk)->sk_lock));				\
  1358		lockdep_set_class_and_name(&(sk)->sk_lock.slock,		\
  1359					(skey), (sname));				\
  1360		lockdep_init_map(&(sk)->sk_lock.dep_map, (name), (key), 0);	\
  1361	} while (0)
  1362	
> 1363	static bool lockdep_sock_is_held(const struct sock *csk)
  1364	{
  1365		struct sock *sk = (struct sock *)csk;
  1366	
> 1367		return lockdep_is_held(&sk->sk_lock) ||
  1368		       lockdep_is_held(&sk->sk_lock.slock);
  1369	}
  1370	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--4Ckj6UjgE2iN1+kY
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--4Ckj6UjgE2iN1+kY--
