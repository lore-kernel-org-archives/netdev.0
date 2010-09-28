From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH v11 13/17] Add mp(mediate passthru) device.
Date: Tue, 28 Sep 2010 11:48:34 -0700
Message-ID: <4CA23882.1030909@us.ibm.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com> <201009281639.59417.arnd@arndb.de> <20100928144311.GB15294@redhat.com> <201009281718.15813.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:32887 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756860Ab0I1Ssp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 14:48:45 -0400
In-Reply-To: <201009281718.15813.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  On 9/28/2010 8:18 AM, Arnd Bergmann wrote:
> On Tuesday 28 September 2010, Michael S. Tsirkin wrote:
>> On Tue, Sep 28, 2010 at 04:39:59PM +0200, Arnd Bergmann wrote:
>>> Can you be more specific what the problem is? Do you think
>>> it breaks when a guest sends VLAN tagged frames or when macvtap
>>> is connected to a VLAN interface that adds another tag (or
>>> only the combination)?
>> I expect the protocol value to be wrong when guest sends vlan tagged
>> frames as 802.1q frames have a different format.
> Ok, I see. Would that be fixed by using eth_type_trans()? I don't
> see any code in there that tries to deal with the VLAN tag, so
> do we have the same problem in the tun/tap driver?
tun_get_user() does call eth_type_trans(). Not sure why i didn't use it 
in macvtap code.
Need to test it with guest VLAN tagging to make sure it works.
> Also, I wonder how we handle the case where both the guest and
> the host do VLAN tagging. Does the host transparently override
> the guest tag, or does it add a nested tag? More importantly,
> what should it do?
> 	
I would think If both guest and host do VLAN tagging, the tags will be 
nested.

Thanks
Sridhar



