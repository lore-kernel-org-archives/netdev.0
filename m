From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 05/14] tcp: track data delivery rate for a TCP
 connection
Date: Sat, 17 Sep 2016 05:38:20 +0800
Message-ID: <201609170509.mUNO6Hq1%fengguang.wu@intel.com>
References: <1474051743-13311-6-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="cWoXeonUoKmBZSoM"
Cc: kbuild-all@01.org, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
        Van Jacobson <vanj@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:53942 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751968AbcIPVjK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 17:39:10 -0400
Content-Disposition: inline
In-Reply-To: <1474051743-13311-6-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Yuchung,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Neal-Cardwell/tcp-BBR-congestion-control-algorithm/20160917-025323
config: cris-etrax-100lx_v2_defconfig (attached as .config)
compiler: cris-linux-gcc (GCC) 6.2.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=cris 

All warnings (new ones prefixed by >>):

   In file included from net/ipv4/route.c:103:0:
>> include/net/tcp.h:769:11: warning: 'packed' attribute ignored for field of type 'struct skb_mstamp' [-Wattributes]
       struct skb_mstamp first_tx_mstamp __packed;
              ^~~~~~~~~~
   include/net/tcp.h:771:11: warning: 'packed' attribute ignored for field of type 'struct skb_mstamp' [-Wattributes]
       struct skb_mstamp delivered_mstamp __packed;
              ^~~~~~~~~~

vim +769 include/net/tcp.h

   753	#define TCPCB_TAGBITS		0x07	/* All tag bits			*/
   754	#define TCPCB_REPAIRED		0x10	/* SKB repaired (no skb_mstamp)	*/
   755	#define TCPCB_EVER_RETRANS	0x80	/* Ever retransmitted frame	*/
   756	#define TCPCB_RETRANS		(TCPCB_SACKED_RETRANS|TCPCB_EVER_RETRANS| \
   757					TCPCB_REPAIRED)
   758	
   759		__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
   760		__u8		txstamp_ack:1,	/* Record TX timestamp for ack? */
   761				eor:1,		/* Is skb MSG_EOR marked? */
   762				unused:6;
   763		__u32		ack_seq;	/* Sequence number ACK'd	*/
   764		union {
   765			struct {
   766				/* There is space for up to 24 bytes */
   767				__u32 in_flight;/* Bytes in flight when packet sent */
   768				/* start of send pipeline phase */
 > 769				struct skb_mstamp first_tx_mstamp __packed;
   770				/* when we reached the "delivered" count */
   771				struct skb_mstamp delivered_mstamp __packed;
   772				/* pkts S/ACKed so far upon tx of skb, incl retrans: */
   773				__u32 delivered;
   774			} tx;   /* only used for outgoing skbs */
   775			union {
   776				struct inet_skb_parm	h4;
   777	#if IS_ENABLED(CONFIG_IPV6)

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--cWoXeonUoKmBZSoM
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
c0yxUv1Aif8DP+wPHs98AAA=

--cWoXeonUoKmBZSoM--
