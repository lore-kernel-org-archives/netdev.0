From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH 2/2] net: Discard and warn about LRO'd skbs received for forwarding
Date: Thu, 19 Jun 2008 15:29:05 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5205732065@orsmsx418.amr.corp.intel.com>
References: <cover.1213898165.git.bhutchings@solarflare.com><20080619180833.GU5350@solarflare.com> <20080619145015.3ec2307c@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>,
	"Kieran Mansley" <kmansley@solarflare.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>
To: "Stephen Hemminger" <shemminger@vyatta.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29221 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752638AbYFSW3I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 18:29:08 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080619145015.3ec2307c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Thu, 19 Jun 2008 19:08:34 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
>> Add skb_warn_if_lro() to test whether an skb was received with LRO
>> and warn if so. 
>> 
>> Change br_forward(), ip_forward() and ip6_forward() to call it) and
>> discard the skb if it returns true.
> 
> Actually shouldn't ip forwarding work because of refragmentation?

Yes, it should, but in practice it runs out of fragment handling space
and throughput drops to 10kB/s or something horrible like that, AFAIR.
