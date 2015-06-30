From: Julien Grall <julien.grall@citrix.com>
Subject: Re: [Xen-devel] Unable to unregister netdevice after "netfilter:
 bridge: forward IPv6 fragmented packets"
Date: Tue, 30 Jun 2015 11:33:57 +0100
Message-ID: <55927095.1060607@citrix.com>
References: <55916C5D.3080602@citrix.com>
 <20150629185525.GF2324@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <bridge@lists.linux-foundation.org>,
	<stephen@networkplumber.org>, <bernhard.thaler@wvnet.at>,
	xen-devel <xen-devel@lists.xenproject.org>,
	<pablo@netfilter.org>, David Vrabel <david.vrabel@citrix.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:10529 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750973AbbF3KfC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2015 06:35:02 -0400
In-Reply-To: <20150629185525.GF2324@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On 29/06/15 19:55, Florian Westphal wrote:
> Julien Grall <julien.grall@citrix.com> wrote:
>> I tried to run the latest Linux tree
>> (4a10a91756ef381bced7b88cfb9232f660b92d93) as DOM0 Xen.
>> After destroying a guest using network, I got the following
>> lines in the DOM0 kernel log:
>>
>> unregister_netdevice: waiting for vif1.0 to become free. Usage count = 1
>>
>> The bisector pointed the problem after the commit
>> efb6de9b4ba0092b2c55f6a52d16294a8a698edd
>> "netfilter: bridge: forward IPv6 fragmented packets".
> 
> Seems we can leak skb in br_nf_dev_queue_xmit()...  Does this fix the problem?

It doesn't resolve the problem. I added some printk to see if the fixed
paths are executed and I don't see any.

Regards,


-- 
Julien Grall
