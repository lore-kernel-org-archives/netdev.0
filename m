From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 1/8] net: ipv4: refactor
 __ip_route_output_key_hash
Date: Thu, 25 May 2017 10:38:02 +0800
Message-ID: <201705251041.sznZ0knO%fengguang.wu@intel.com>
References: <1495649951-30417-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PNTmBPCT7hxwcZjr"
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
        dsahern@gmail.com, nikolay@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19786 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941195AbdEYCii (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 22:38:38 -0400
Content-Disposition: inline
In-Reply-To: <1495649951-30417-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi David,

[auto build test ERROR on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Roopa-Prabhu/net-extend-RTM_GETROUTE-to-return-fib-result/20170525-053253
config: openrisc-or1ksim_defconfig (attached as .config)
compiler: or1k-linux-gcc (GCC) 5.4.0
reproduce:
        wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=openrisc 

Note: the linux-review/Roopa-Prabhu/net-extend-RTM_GETROUTE-to-return-fib-result/20170525-053253 HEAD 083c4ee9e124d0acf29d159ced8a22cb41665a7a builds fine.
      It only hurts bisectibility.

All errors (new ones prefixed by >>):

   In file included from include/net/route.h:31:0,
                    from include/net/lwtunnel.h:8,
                    from include/net/ip_tunnels.h:17,
                    from include/net/dst_metadata.h:5,
                    from net/ipv4/route.c:94:
   net/ipv4/route.c: In function 'ip_route_output_key_hash_rcu':
>> include/net/ip_fib.h:167:32: error: request for member 'fi' in something not a structure or union
    #define FIB_RES_NH(res)  ((res).fi->fib_nh[0])
                                   ^
   include/net/ip_fib.h:196:28: note: in expansion of macro 'FIB_RES_NH'
    #define FIB_RES_DEV(res)  (FIB_RES_NH(res).nh_dev)
                               ^
   net/ipv4/route.c:2399:35: note: in expansion of macro 'FIB_RES_DEV'
      dev_out = l3mdev_master_dev_rcu(FIB_RES_DEV(res)) ? :
                                      ^
   net/ipv4/route.c: In function 'ip_route_output_key_hash':
   net/ipv4/route.c:2430:53: error: 'mp_hash' undeclared (first use in this function)
     rth = ip_route_output_key_hash_rcu(net, fl4, &res, mp_hash);
                                                        ^
   net/ipv4/route.c:2430:53: note: each undeclared identifier is reported only once for each function it appears in
   net/ipv4/route.c:2430:47: error: passing argument 3 of 'ip_route_output_key_hash_rcu' from incompatible pointer type [-Werror=incompatible-pointer-types]
     rth = ip_route_output_key_hash_rcu(net, fl4, &res, mp_hash);
                                                  ^
   net/ipv4/route.c:2249:16: note: expected 'const struct sk_buff *' but argument is of type 'struct fib_result *'
    struct rtable *ip_route_output_key_hash_rcu(struct net *net, struct flowi4 *fl4,
                   ^
   cc1: some warnings being treated as errors
--
   In file included from include/net/route.h:31:0,
                    from include/net/lwtunnel.h:8,
                    from include/net/ip_tunnels.h:17,
                    from include/net/dst_metadata.h:5,
                    from net//ipv4/route.c:94:
   net//ipv4/route.c: In function 'ip_route_output_key_hash_rcu':
>> include/net/ip_fib.h:167:32: error: request for member 'fi' in something not a structure or union
    #define FIB_RES_NH(res)  ((res).fi->fib_nh[0])
                                   ^
   include/net/ip_fib.h:196:28: note: in expansion of macro 'FIB_RES_NH'
    #define FIB_RES_DEV(res)  (FIB_RES_NH(res).nh_dev)
                               ^
   net//ipv4/route.c:2399:35: note: in expansion of macro 'FIB_RES_DEV'
      dev_out = l3mdev_master_dev_rcu(FIB_RES_DEV(res)) ? :
                                      ^
   net//ipv4/route.c: In function 'ip_route_output_key_hash':
   net//ipv4/route.c:2430:53: error: 'mp_hash' undeclared (first use in this function)
     rth = ip_route_output_key_hash_rcu(net, fl4, &res, mp_hash);
                                                        ^
   net//ipv4/route.c:2430:53: note: each undeclared identifier is reported only once for each function it appears in
   net//ipv4/route.c:2430:47: error: passing argument 3 of 'ip_route_output_key_hash_rcu' from incompatible pointer type [-Werror=incompatible-pointer-types]
     rth = ip_route_output_key_hash_rcu(net, fl4, &res, mp_hash);
                                                  ^
   net//ipv4/route.c:2249:16: note: expected 'const struct sk_buff *' but argument is of type 'struct fib_result *'
    struct rtable *ip_route_output_key_hash_rcu(struct net *net, struct flowi4 *fl4,
                   ^
   cc1: some warnings being treated as errors

vim +/fi +167 include/net/ip_fib.h

5f300893f Thomas Graf    2006-11-09  151  	u32		fl_mark;
246955fe4 Robert Olsson  2005-06-20  152  	unsigned char	fl_tos;
246955fe4 Robert Olsson  2005-06-20  153  	unsigned char   fl_scope;
246955fe4 Robert Olsson  2005-06-20  154  	unsigned char   tb_id_in;
246955fe4 Robert Olsson  2005-06-20  155  
246955fe4 Robert Olsson  2005-06-20  156  	unsigned char   tb_id;      /* Results */
246955fe4 Robert Olsson  2005-06-20  157  	unsigned char	prefixlen;
246955fe4 Robert Olsson  2005-06-20  158  	unsigned char	nh_sel;
246955fe4 Robert Olsson  2005-06-20  159  	unsigned char	type;
246955fe4 Robert Olsson  2005-06-20  160  	unsigned char	scope;
246955fe4 Robert Olsson  2005-06-20  161  	int             err;      
246955fe4 Robert Olsson  2005-06-20  162  };
^1da177e4 Linus Torvalds 2005-04-16  163  
^1da177e4 Linus Torvalds 2005-04-16  164  #ifdef CONFIG_IP_ROUTE_MULTIPATH
^1da177e4 Linus Torvalds 2005-04-16  165  #define FIB_RES_NH(res)		((res).fi->fib_nh[(res).nh_sel])
^1da177e4 Linus Torvalds 2005-04-16  166  #else /* CONFIG_IP_ROUTE_MULTIPATH */
^1da177e4 Linus Torvalds 2005-04-16 @167  #define FIB_RES_NH(res)		((res).fi->fib_nh[0])
5b9e12dbf Denis V. Lunev 2013-03-13  168  #endif /* CONFIG_IP_ROUTE_MULTIPATH */
^1da177e4 Linus Torvalds 2005-04-16  169  
5b9e12dbf Denis V. Lunev 2013-03-13  170  #ifdef CONFIG_IP_MULTIPLE_TABLES
93456b6d7 Denis V. Lunev 2008-01-10  171  #define FIB_TABLE_HASHSZ 256
5b9e12dbf Denis V. Lunev 2013-03-13  172  #else
5b9e12dbf Denis V. Lunev 2013-03-13  173  #define FIB_TABLE_HASHSZ 2
5b9e12dbf Denis V. Lunev 2013-03-13  174  #endif
^1da177e4 Linus Torvalds 2005-04-16  175  

:::::: The code at line 167 was first introduced by commit
:::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2

:::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
:::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--PNTmBPCT7hxwcZjr
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--PNTmBPCT7hxwcZjr--
