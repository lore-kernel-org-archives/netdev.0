From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH v2 0/7] via-velocity performance fixes
Date: Mon, 23 Nov 2009 15:27:24 +0100
Message-ID: <20091123152724.2871cf4d@marrow.netinsight.se>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:62229 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753308AbZKWO10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 09:27:26 -0500
In-Reply-To: <20091120160633.77b7aee0@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again!

This is version two of the series posted here:

   http://marc.info/?l=linux-netdev&m=125873023117769&w=2

The new version tries to integrate Stephen and Davids comments, and
also some general improvements which I've done. There are 7 patches:

1. See to it that data is 64-byte aligned (same as before)

2. Add ethtool interrupt coalescing support. This is the old "adaptive
   interrupt suppression" patch, which is now implemented through the
   ethtool interface. Both tx/rx frames and tx/rx time can be
   controlled. The module parameters have been removed.

   The default is everything off (i.e., as before).

3. NAPI support for via-velocity (same as before, but rebased)

4. Change DMA length default (same as before, rebased)

5. Re-enable scatter-gather support. This is also implemented through
   ethtool, and therefore needs to be turned on. It's not always a win,
   but for some netperf runs it improves stuff.

6. Set tx checksum from ethtool instead of a module parameter (new
   patch)

7. Bump the version.


To get the same performance results as before, you now need to setup
interrupt supression with

   ethtool -C eth-swa rx-usecs 20 tx-usecs 100 tx-frames 31 rx-frames 31

(which are the defaults from the VIA driver)

// Simon
