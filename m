From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v1 4/4] ixgbe: enable FDB netdevice ops
Date: Fri, 09 Mar 2012 21:06:10 -0800
Message-ID: <4F5AE142.7050702@intel.com>
References: <ba6647b4-1242-4753-9e97-9a2f5515b20c@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, roprabhu@cisco.com, netdev@vger.kernel.org,
	mst@redhat.com, chrisw@redhat.com, davem@davemloft.net,
	gregory v rose <gregory.v.rose@intel.com>,
	kvm@vger.kernel.org, sri@us.ibm.com, chealy@imsco-us.com,
	jhs@mojatatu.com, bhutchings@solarflare.com
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:21197 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750718Ab2CJFGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 00:06:12 -0500
In-Reply-To: <ba6647b4-1242-4753-9e97-9a2f5515b20c@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/9/2012 7:48 PM, Stephen Hemminger wrote:
> 
>> Enable FDB ops on ixgbe when in SR-IOV mode.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> Will all this break anything on the vf client? What if the vf is running
> a bridge.

No shouldn't break anything.

Actually, implementing these ops in the VF driver (ixgbevf in this
case) will allow bridging to work on the VF. Because at least on
the intel 82599 devices the VF can't be put in promiscuous mode
so bridging doesn't work as expected. With the ops implemented
we could at least get traffic forwarded correctly for addresses
that were known above the VF.
