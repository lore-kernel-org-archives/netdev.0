From: Dan Carpenter <error27@gmail.com>
Subject: ixgbevf: bug in error handling
Date: Thu, 11 Mar 2010 13:33:29 +0300
Message-ID: <20100311103329.GO6321@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:50262 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755349Ab0CKKkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 05:40:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

drivers/net/ixgbevf/ixgbevf_main.c +3013 ixgbevf_tx_map(96) warn: unsigned 'i' is never less than zero.
  3010          while (count >= 0) {
  3011                  count--;
  3012                  i--;
  3013                  if (i < 0)
  3014                          i += tx_ring->count;

	There is a problem here because i is unsigned and just wraps 
	around instead of being less than 0.

  3015                  tx_buffer_info = &tx_ring->tx_buffer_info[i];
  3016                  ixgbevf_unmap_and_free_tx_resource(adapter, tx_buffer_info);
  3017          }

regards,
dan carpenter
