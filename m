From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: set is_local and is_static before fdb
 entry is added to the fdb hashtable
Date: Tue, 27 Oct 2015 05:06:19 -0700
Message-ID: <562F68BB.1040201@cumulusnetworks.com>
References: <201510271206.HPbBjdTp%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, davem@davemloft.net, stephen@networkplumber.org,
	nikolay@cumulusnetworks.com, netdev@vger.kernel.org
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33474 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639AbbJ0MGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 08:06:21 -0400
Received: by pabla5 with SMTP id la5so28183984pab.0
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 05:06:21 -0700 (PDT)
In-Reply-To: <201510271206.HPbBjdTp%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/15, 9:16 PM, kbuild test robot wrote:
> Hi Roopa,
>
> [auto build test ERROR on net-next/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]
>
> url:    https://github.com/0day-ci/linux/commits/Roopa-Prabhu/bridge-set-is_local-and-is_static-before-fdb-entry-is-added-to-the-fdb-hashtable/20151027-120635
> config: i386-randconfig-x009-201543 (attached as .config)
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
>
> All errors (new ones prefixed by >>):
>
>    net/bridge/br_fdb.c: In function 'br_fdb_external_learn_add':
>>> net/bridge/br_fdb.c:1103:9: error: too few arguments to function 'fdb_create'
>       fdb = fdb_create(head, p, addr, vid);
>             ^
>    net/bridge/br_fdb.c:495:37: note: declared here
>     static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
>                                         ^
>
> vim +/fdb_create +1103 net/bridge/br_fdb.c
>
> 3aeb6617 Jiri Pirko    2015-01-15  1097  	ASSERT_RTNL();
> cf6b8e1e Scott Feldman 2014-11-28  1098  	spin_lock_bh(&br->hash_lock);
> cf6b8e1e Scott Feldman 2014-11-28  1099  
> cf6b8e1e Scott Feldman 2014-11-28  1100  	head = &br->hash[br_mac_hash(addr, vid)];
> cf6b8e1e Scott Feldman 2014-11-28  1101  	fdb = fdb_find(head, addr, vid);
> cf6b8e1e Scott Feldman 2014-11-28  1102  	if (!fdb) {
> cf6b8e1e Scott Feldman 2014-11-28 @1103  		fdb = fdb_create(head, p, addr, vid);
> cf6b8e1e Scott Feldman 2014-11-28  1104  		if (!fdb) {
> cf6b8e1e Scott Feldman 2014-11-28  1105  			err = -ENOMEM;
> cf6b8e1e Scott Feldman 2014-11-28  1106  			goto err_unlock;
>
> :::::: The code at line 1103 was first introduced by commit
> :::::: cf6b8e1eedffd9ef9a22c0c9453d752b07daf89a bridge: add API to notify bridge driver of learned FBD on offloaded device
>
> :::::: TO: Scott Feldman <sfeldma@gmail.com>
> :::::: CC: David S. Miller <davem@davemloft.net>
>
sorry, looks like i posted an older version. Re-posting. Thanks.
