From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 194/196] include/net/sock.h:1367:9: error: implicit
 declaration of function 'lockdep_is_held'
Date: Fri, 8 Apr 2016 05:00:42 +0800
Message-ID: <201604080541.jzrX1awl%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nFreZHaLTZJo0R7j"
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:31920 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932107AbcDGVB3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 17:01:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   1fbbe1a8a9b195c4ac856540dfaef49d663c2e91
commit: 1e1d04e678cf72442f57ce82803c7a407769135f [194/196] net: introduce lockdep_is_held and update various places to use it
config: i386-tinyconfig (attached as .config)
reproduce:
        git checkout 1e1d04e678cf72442f57ce82803c7a407769135f
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   In file included from include/linux/tcp.h:22:0,
                    from include/linux/ipv6.h:75,
                    from include/net/ipv6.h:16,
                    from include/linux/sunrpc/clnt.h:27,
                    from include/linux/nfs_fs.h:30,
                    from init/do_mounts.c:32:
   include/net/sock.h: In function 'lockdep_sock_is_held':
>> include/net/sock.h:1367:9: error: implicit declaration of function 'lockdep_is_held' [-Werror=implicit-function-declaration]
     return lockdep_is_held(&sk->sk_lock) ||
            ^
   init/do_mounts.c: At top level:
   include/net/sock.h:1363:13: warning: 'lockdep_sock_is_held' defined but not used [-Wunused-function]
    static bool lockdep_sock_is_held(const struct sock *csk)
                ^
   cc1: some warnings being treated as errors

vim +/lockdep_is_held +1367 include/net/sock.h

  1361	} while (0)
  1362	
  1363	static bool lockdep_sock_is_held(const struct sock *csk)
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

--nFreZHaLTZJo0R7j
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
gv+cQcK5dlgAAA==

--nFreZHaLTZJo0R7j--
