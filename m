From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 641/694] include/net/request_sock.h:198:9: sparse:
 context imbalance in 'tcp_conn_request' - unexpected unlock
Date: Tue, 6 Oct 2015 00:14:01 +0800
Message-ID: <201510060055.ybaeZ9eH%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:14050 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751024AbbJEQOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2015 12:14:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   4560cdff03a76348ee5fae48e3c7914e4de2db5b
commit: 7656d842de93fd2d2de7b403062cad757cadf1df [641/694] tcp: fix fastopen races vs lockless listener
reproduce:
        # apt-get install sparse
        git checkout 7656d842de93fd2d2de7b403062cad757cadf1df
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> include/net/request_sock.h:198:9: sparse: context imbalance in 'tcp_conn_request' - unexpected unlock

vim +/tcp_conn_request +198 include/net/request_sock.h

0e87506f Arnaldo Carvalho de Melo 2005-06-18  182  }
0e87506f Arnaldo Carvalho de Melo 2005-06-18  183  
0e87506f Arnaldo Carvalho de Melo 2005-06-18  184  static inline void reqsk_queue_add(struct request_sock_queue *queue,
0e87506f Arnaldo Carvalho de Melo 2005-06-18  185  				   struct request_sock *req,
0e87506f Arnaldo Carvalho de Melo 2005-06-18  186  				   struct sock *parent,
0e87506f Arnaldo Carvalho de Melo 2005-06-18  187  				   struct sock *child)
0e87506f Arnaldo Carvalho de Melo 2005-06-18  188  {
fff1f300 Eric Dumazet             2015-10-02  189  	spin_lock(&queue->rskq_lock);
0e87506f Arnaldo Carvalho de Melo 2005-06-18  190  	req->sk = child;
0e87506f Arnaldo Carvalho de Melo 2005-06-18  191  	sk_acceptq_added(parent);
0e87506f Arnaldo Carvalho de Melo 2005-06-18  192  
0e87506f Arnaldo Carvalho de Melo 2005-06-18  193  	if (queue->rskq_accept_head == NULL)
0e87506f Arnaldo Carvalho de Melo 2005-06-18  194  		queue->rskq_accept_head = req;
0e87506f Arnaldo Carvalho de Melo 2005-06-18  195  	else
0e87506f Arnaldo Carvalho de Melo 2005-06-18  196  		queue->rskq_accept_tail->dl_next = req;
0e87506f Arnaldo Carvalho de Melo 2005-06-18  197  
0e87506f Arnaldo Carvalho de Melo 2005-06-18 @198  	queue->rskq_accept_tail = req;
0e87506f Arnaldo Carvalho de Melo 2005-06-18  199  	req->dl_next = NULL;
fff1f300 Eric Dumazet             2015-10-02  200  	spin_unlock(&queue->rskq_lock);
0e87506f Arnaldo Carvalho de Melo 2005-06-18  201  }
0e87506f Arnaldo Carvalho de Melo 2005-06-18  202  
fff1f300 Eric Dumazet             2015-10-02  203  static inline struct request_sock *reqsk_queue_remove(struct request_sock_queue *queue,
fff1f300 Eric Dumazet             2015-10-02  204  						      struct sock *parent)
0e87506f Arnaldo Carvalho de Melo 2005-06-18  205  {
fff1f300 Eric Dumazet             2015-10-02  206  	struct request_sock *req;

:::::: The code at line 198 was first introduced by commit
:::::: 0e87506fcc734647c7b2497eee4eb81e785c857a [NET] Generalise tcp_listen_opt

:::::: TO: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
