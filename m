From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH v4 0/7] via-velocity performance fixes
Date: Thu, 26 Nov 2009 09:04:29 +0100
Message-ID: <20091126090429.39cb37ac@marrow.netinsight.se>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091123152724.2871cf4d@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:26146 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1759368AbZKZIE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 03:04:29 -0500
In-Reply-To: <20091123152724.2871cf4d@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again!

This is version four of the series posted here:

   http://marc.info/?l=linux-netdev&m=125873023117769&w=2

The new version integrates Davids comments. There are 7 patches:

1. See to it that data is 64-byte aligned (same as before)

2. Add ethtool interrupt coalescing support. (same as before)

3. NAPI support for via-velocity (same as before)

4. Change DMA length default (same as before)

5. Re-enable scatter-gather support. (removed the double-check of
   nr_frags according to Davids comment)

6. Set tx checksum from ethtool instead of a module parameter (rebased)

7. Bump the version.


To get the same performance results (or better!) as with the VIA
driver, you now need to setup interrupt supression with

   ethtool -C ethX rx-usecs 20 tx-usecs 100 tx-frames 31 rx-frames 31

(which are the defaults from the VIA driver). Scatter-gather support is
enabled with

   ethtool -K ethX sg on

// Simon
