From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: ixgbe: fixup hard dependencies on supporting 8
	traffic classes
Date: Wed, 12 Oct 2011 09:35:55 +0300
Message-ID: <20111012063555.GA23359@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hello John Fastabend,

This is a semi-automatic email about new static checker warnings.

The patch 32701dc2e616: "ixgbe: fixup hard dependencies on supporting
8 traffic classes" from Sep 27, 2011, leads to the following Smatch
complaint:

drivers/net/ethernet/intel/ixgbe/ixgbe_main.c +3366 ixgbe_configure_dcb()
	 error: we previously assumed 'adapter->ixgbe_ieee_ets' could be null (see line 3357)

drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
  3356	
  3357			if (adapter->ixgbe_ieee_ets) {
                            ^^^^^^^^^^^^^^^^^^^^^^^
Null check.

  3358				struct ieee_ets *ets = adapter->ixgbe_ieee_ets;
  3359				int max_frame = dev->mtu + ETH_HLEN + ETH_FCS_LEN;
  3360	
  3361				ixgbe_dcb_hw_ets(&adapter->hw, ets, max_frame);
  3362			}
  3363	
  3364			if (adapter->ixgbe_ieee_pfc) {
  3365				struct ieee_pfc *pfc = adapter->ixgbe_ieee_pfc;
  3366				u8 *prio_tc = adapter->ixgbe_ieee_ets->prio_tc;
                                              ^^^^^^^^^^^^^^^^^^^^^^^^^
New dereference.

  3367	
  3368				ixgbe_dcb_hw_pfc_config(&adapter->hw, pfc->pfc_en,

regards,
dan carpenter


------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure contains a
definitive record of customers, application performance, security
threats, fraudulent activity and more. Splunk takes this data and makes
sense of it. Business sense. IT sense. Common sense.
http://p.sf.net/sfu/splunk-d2d-oct
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
