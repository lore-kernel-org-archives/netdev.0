From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 1/8] net: ipv4: refactor
 __ip_route_output_key_hash
Date: Thu, 25 May 2017 09:30:28 +0800
Message-ID: <201705250946.HTEN2jls%fengguang.wu@intel.com>
References: <1495649951-30417-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AqsLC8rIMeq19msA"
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
        dsahern@gmail.com, nikolay@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57608 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1423291AbdEYBba (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 21:31:30 -0400
Content-Disposition: inline
In-Reply-To: <1495649951-30417-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi David,

[auto build test ERROR on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Roopa-Prabhu/net-extend-RTM_GETROUTE-to-return-fib-result/20170525-053253
config: cris-etrax-100lx_v2_defconfig (attached as .config)
compiler: cris-linux-gcc (GCC) 6.2.0
reproduce:
        wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=cris 

Note: the linux-review/Roopa-Prabhu/net-extend-RTM_GETROUTE-to-return-fib-result/20170525-053253 HEAD 083c4ee9e124d0acf29d159ced8a22cb41665a7a builds fine.
      It only hurts bisectibility.

All error/warnings (new ones prefixed by >>):

   In file included from include/net/route.h:31:0,
                    from include/net/lwtunnel.h:8,
                    from include/net/ip_tunnels.h:17,
                    from include/net/dst_metadata.h:5,
                    from net/ipv4/route.c:94:
   net/ipv4/route.c: In function 'ip_route_output_key_hash_rcu':
>> include/net/ip_fib.h:167:32: error: 'res' is a pointer; did you mean to use '->'?
    #define FIB_RES_NH(res)  ((res).fi->fib_nh[0])
                                   ^
                                      ->
>> include/net/ip_fib.h:196:28: note: in expansion of macro 'FIB_RES_NH'
    #define FIB_RES_DEV(res)  (FIB_RES_NH(res).nh_dev)
                               ^~~~~~~~~~
>> net/ipv4/route.c:2399:35: note: in expansion of macro 'FIB_RES_DEV'
      dev_out = l3mdev_master_dev_rcu(FIB_RES_DEV(res)) ? :
                                      ^~~~~~~~~~~
   net/ipv4/route.c: In function 'ip_route_output_key_hash':
>> net/ipv4/route.c:2430:53: error: 'mp_hash' undeclared (first use in this function)
     rth = ip_route_output_key_hash_rcu(net, fl4, &res, mp_hash);
                                                        ^~~~~~~
   net/ipv4/route.c:2430:53: note: each undeclared identifier is reported only once for each function it appears in
>> net/ipv4/route.c:2430:47: error: passing argument 3 of 'ip_route_output_key_hash_rcu' from incompatible pointer type [-Werror=incompatible-pointer-types]
     rth = ip_route_output_key_hash_rcu(net, fl4, &res, mp_hash);
                                                  ^
   net/ipv4/route.c:2249:16: note: expected 'const struct sk_buff *' but argument is of type 'struct fib_result *'
    struct rtable *ip_route_output_key_hash_rcu(struct net *net, struct flowi4 *fl4,
                   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors
--
   In file included from include/net/route.h:31:0,
                    from include/net/lwtunnel.h:8,
                    from include/net/ip_tunnels.h:17,
                    from include/net/dst_metadata.h:5,
                    from net//ipv4/route.c:94:
   net//ipv4/route.c: In function 'ip_route_output_key_hash_rcu':
>> include/net/ip_fib.h:167:32: error: 'res' is a pointer; did you mean to use '->'?
    #define FIB_RES_NH(res)  ((res).fi->fib_nh[0])
                                   ^
                                      ->
>> include/net/ip_fib.h:196:28: note: in expansion of macro 'FIB_RES_NH'
    #define FIB_RES_DEV(res)  (FIB_RES_NH(res).nh_dev)
                               ^~~~~~~~~~
   net//ipv4/route.c:2399:35: note: in expansion of macro 'FIB_RES_DEV'
      dev_out = l3mdev_master_dev_rcu(FIB_RES_DEV(res)) ? :
                                      ^~~~~~~~~~~
   net//ipv4/route.c: In function 'ip_route_output_key_hash':
   net//ipv4/route.c:2430:53: error: 'mp_hash' undeclared (first use in this function)
     rth = ip_route_output_key_hash_rcu(net, fl4, &res, mp_hash);
                                                        ^~~~~~~
   net//ipv4/route.c:2430:53: note: each undeclared identifier is reported only once for each function it appears in
   net//ipv4/route.c:2430:47: error: passing argument 3 of 'ip_route_output_key_hash_rcu' from incompatible pointer type [-Werror=incompatible-pointer-types]
     rth = ip_route_output_key_hash_rcu(net, fl4, &res, mp_hash);
                                                  ^
   net//ipv4/route.c:2249:16: note: expected 'const struct sk_buff *' but argument is of type 'struct fib_result *'
    struct rtable *ip_route_output_key_hash_rcu(struct net *net, struct flowi4 *fl4,
                   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/mp_hash +2430 net/ipv4/route.c

  2393					fl4->saddr = res->fi->fib_prefsrc;
  2394				else
  2395					fl4->saddr = fl4->daddr;
  2396			}
  2397	
  2398			/* L3 master device is the loopback for that domain */
> 2399			dev_out = l3mdev_master_dev_rcu(FIB_RES_DEV(res)) ? :
  2400				net->loopback_dev;
  2401			fl4->flowi4_oif = dev_out->ifindex;
  2402			flags |= RTCF_LOCAL;
  2403			goto make_route;
  2404		}
  2405	
  2406		fib_select_path(net, res, fl4, skb);
  2407	
  2408		dev_out = FIB_RES_DEV(*res);
  2409		fl4->flowi4_oif = dev_out->ifindex;
  2410	
  2411	
  2412	make_route:
  2413		rth = __mkroute_output(res, fl4, orig_oif, dev_out, flags);
  2414	
  2415	out:
  2416		return rth;
  2417	}
  2418	
  2419	struct rtable *ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
  2420						const struct sk_buff *skb)
  2421	{
  2422		struct fib_result res;
  2423		struct rtable *rth;
  2424	
  2425		res.tclassid	= 0;
  2426		res.fi		= NULL;
  2427		res.table	= NULL;
  2428	
  2429		rcu_read_lock();
> 2430		rth = ip_route_output_key_hash_rcu(net, fl4, &res, mp_hash);
  2431		rcu_read_unlock();
  2432	
  2433		return rth;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--AqsLC8rIMeq19msA
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--AqsLC8rIMeq19msA--
