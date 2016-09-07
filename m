From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next] net: inet: diag: expose the socket mark to
 privileged processes.
Date: Wed, 7 Sep 2016 19:32:50 +0800
Message-ID: <201609071917.EMi0Gvhi%fengguang.wu@intel.com>
References: <1473240756-101966-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, ek@google.com,
        eric.dumazet@gmail.com, davem@davemloft.net,
        dsa@cumulusnetworks.com, Lorenzo Colitti <lorenzo@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52471 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1422649AbcIGLdv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 07:33:51 -0400
Content-Disposition: inline
In-Reply-To: <1473240756-101966-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lorenzo,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Lorenzo-Colitti/net-inet-diag-expose-the-socket-mark-to-privileged-processes/20160907-181944
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:230:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> net/sctp/sctp_diag.c:136:37: sparse: not enough arguments for function inet_diag_msg_attrs_fill
   net/sctp/sctp_diag.c: In function 'inet_sctp_diag_fill':
   net/sctp/sctp_diag.c:136:6: error: too few arguments to function 'inet_diag_msg_attrs_fill'
     if (inet_diag_msg_attrs_fill(sk, skb, r, ext, user_ns))
         ^~~~~~~~~~~~~~~~~~~~~~~~
   In file included from net/sctp/sctp_diag.c:2:0:
   include/linux/inet_diag.h:57:5: note: declared here
    int inet_diag_msg_attrs_fill(struct sock *sk, struct sk_buff *skb,
        ^~~~~~~~~~~~~~~~~~~~~~~~

vim +136 net/sctp/sctp_diag.c

8f840e47 Xin Long 2016-04-14  120  			nlmsg_flags);
8f840e47 Xin Long 2016-04-14  121  	if (!nlh)
8f840e47 Xin Long 2016-04-14  122  		return -EMSGSIZE;
8f840e47 Xin Long 2016-04-14  123  
8f840e47 Xin Long 2016-04-14  124  	r = nlmsg_data(nlh);
8f840e47 Xin Long 2016-04-14  125  	BUG_ON(!sk_fullsock(sk));
8f840e47 Xin Long 2016-04-14  126  
8f840e47 Xin Long 2016-04-14  127  	if (asoc) {
8f840e47 Xin Long 2016-04-14  128  		inet_diag_msg_sctpasoc_fill(r, sk, asoc);
8f840e47 Xin Long 2016-04-14  129  	} else {
8f840e47 Xin Long 2016-04-14  130  		inet_diag_msg_common_fill(r, sk);
8f840e47 Xin Long 2016-04-14  131  		r->idiag_state = sk->sk_state;
8f840e47 Xin Long 2016-04-14  132  		r->idiag_timer = 0;
8f840e47 Xin Long 2016-04-14  133  		r->idiag_retrans = 0;
8f840e47 Xin Long 2016-04-14  134  	}
8f840e47 Xin Long 2016-04-14  135  
8f840e47 Xin Long 2016-04-14 @136  	if (inet_diag_msg_attrs_fill(sk, skb, r, ext, user_ns))
8f840e47 Xin Long 2016-04-14  137  		goto errout;
8f840e47 Xin Long 2016-04-14  138  
8f840e47 Xin Long 2016-04-14  139  	if (ext & (1 << (INET_DIAG_SKMEMINFO - 1))) {
8f840e47 Xin Long 2016-04-14  140  		u32 mem[SK_MEMINFO_VARS];
8f840e47 Xin Long 2016-04-14  141  		int amt;
8f840e47 Xin Long 2016-04-14  142  
8f840e47 Xin Long 2016-04-14  143  		if (asoc && asoc->ep->sndbuf_policy)
8f840e47 Xin Long 2016-04-14  144  			amt = asoc->sndbuf_used;

:::::: The code at line 136 was first introduced by commit
:::::: 8f840e47f190cbe61a96945c13e9551048d42cef sctp: add the sctp_diag.c file

:::::: TO: Xin Long <lucien.xin@gmail.com>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
