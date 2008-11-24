From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [RFC PATCH] lro: ip fragment checking
Date: Mon, 24 Nov 2008 13:04:33 -0800
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A1714B0C9@orsmsx507.amr.corp.intel.com>
References: <492ACEC4.3020702@de.ibm.com> <1227545468.3162.4.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"tklein@de.ibm.com" <tklein@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	"jb.billaud@gmail.com" <jb.billaud@gmail.com>,
	"hering2@de.ibm.com" <hering2@de.ibm.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35692 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752776AbYKXVEh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 16:04:37 -0500
In-Reply-To: <1227545468.3162.4.camel@achroite>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Mon, 2008-11-24 at 16:56 +0100, Jan-Bernd Themann wrote:
>> Currently there is no checking in the LRO receive path whether
>> TCP packets are ip fragmented. We should not consider
>> those packets for aggregation.
>> I'm not sure if this checking is actually required. Does anyone
>> know if it is possible to get fragmented TCP packets without
>> the tcp stack changing the MSS size?
>> This patch introduces explicit checking. Any objections?
> 
> LRO depends on the hardware performing TCP checksum offload, and the
> TCP checksum cannot be verified for IP fragments in isolation.  So I
> think drivers should not be passing fragments into inet_lro or should
> reject them in its get_frag_header() or get_skb_header() method. 
> Certainly sfc doesn't pass fragments into inet_lro because they have
> not been checksummed.

The fragments, definitely will not have checksums offloaded, but
what about the first packet in the chain?  I haven't verified in
ixgbe or igb whether or not it could try and aggregate a packet
with MF set if it was the first fragment in a series of IP fragments.