From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes
 infrequently
Date: Mon, 05 May 2008 18:55:49 -0700
Message-ID: <1210038949.7941.189.camel@dell>
References: <bug-10600-10286@http.bugzilla.kernel.org/>
 <20080505155502.3fb16590.akpm@linux-foundation.org>
 <20080505.161806.267621711.davem@davemloft.net>
 <481F9E64.6070606@acm.org> <1210036624.7941.183.camel@dell>
 <Pine.LNX.4.64.0805060235410.6134@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ben Liblit" <liblit@acm.org>,
	"David Miller" <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
To: "Krzysztof Oledzki" <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4434 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751989AbYEFAvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 20:51:24 -0400
In-Reply-To: <Pine.LNX.4.64.0805060235410.6134@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-05-06 at 02:43 +0200, Krzysztof Oledzki wrote:
> Hm... strange - I tested it on 2.6.23.17 with:
> 03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708
> Gigabit Ethernet (rev 12)
> 
> Setting both:
>   # ethtool -C eth0 stats-block-usecs 50
> and:
>   # ethtool -C eth0 stats-block-usecs 5000000
> gives exactly the same situation - statistics update frequency is
> still ~1s.
> 
> # ethtool -c eth1 |grep stats-block-usecs
> stats-block-usecs: 999936

Unfortunately, 5708 has a bug in the statistics DMA engine that was
reported here on netdev about 1 year ago.  To work around it, we have to
disable the statistics block DMA and rely on the driver's timer function
which runs at a fixed 1 second interval.  So only 0 and 999936 are
allowed values on the 5708.  Newer chips or the older 5706 do not have
this problem.

