From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 0/2] Don't use lco_csum to compute IPv4 checksum
Date: Wed, 30 Nov 2016 09:47:46 -0500 (EST)
Message-ID: <20161130.094746.724735454244491985.davem@davemloft.net>
References: <20161128153927.15466.99193.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        sfr@canb.auug.org.au, jeffrey.t.kirsher@intel.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60564 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753532AbcK3Oru (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 09:47:50 -0500
In-Reply-To: <20161128153927.15466.99193.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 28 Nov 2016 10:42:18 -0500

> When I implemented the GSO partial support in the Intel drivers I was using
> lco_csum to compute the checksum that we needed to plug into the IPv4
> checksum field in order to cancel out the data that was not a part of the
> IPv4 header.  However this didn't take into account that the transport
> offset might be pointing to the inner transport header.
> 
> Instead of using lco_csum I have just coded around it so that we can use
> the outer IP header plus the IP header length to determine where we need to
> start our checksum and then just call csum_partial ourselves.
> 
> This should fix the SIT issue reported on igb interfaces as well as simliar
> issues that would pop up on other Intel NICs.

Jeff, are you going to send me a pull request with this stuff or would
you be OK with my applying these directly to 'net'?

Thanks.
