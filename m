From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [RFC PATCH 00/13] hardware time stamping + igb example	implementation
Date: Wed, 12 Nov 2008 22:34:27 +0100
Message-ID: <491B4BE3.3010104@linux.intel.com>
References: <1226414697.17450.852.camel@ecld0pohly>	 <491AFF09.8070907@linux.intel.com> <1226507118.31699.91.camel@ecld0pohly> <491B23FE.9000105@hartkopp.net> <491B2D03.1090700@cosmosbay.com> <491B3B49.7070402@linux.intel.com> <491B42FF.3000407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	Patrick Ohly <patrick.ohly@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:47005 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751635AbYKLVvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 16:51:04 -0500
In-Reply-To: <491B42FF.3000407@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> This scheme only is needed for special devices, 

It's going to be supported by a large range of mass market NICs,
not special devices.

used by PTP.
> 
> Only *selected* frames really need to gather hwtstamp.

Yes but the NIC cannot decide that.

> TCP trafic wont use hwtstamp. 

Actually it wouldn't surprise me if one of the numerous
TCP congestion avoidance algorithms that get added all the time
starts making use of such an enhanced time stamp.

>Most UDP trafic wont use hwstamp.

That depends. For example if you're running a packet sniffer
most packets will carry it. Probably also others. e.g. dhcp
is using timestamps and it would make sense to switch it to
hw timestamps when available.
Now if you're running a DHCP server ...

> I threw a "crazy idea", that can be changed if necessary, say with a cookie
> that identifies the slot in NIC driver structure. O(1) lookup if really 
> needed.

I think "crazy" describes it well because it would be a lot of dubious
and likely not performing well effort just to save 8 bytes.

BTW it wouldn't surprise me if skb heads had some free space in common
situations anyways becaus it's unlikely it fits exactly into 4K pages
in slab/slub.

-Andi
