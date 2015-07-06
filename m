From: Julien Grall <julien.grall@citrix.com>
Subject: Re: [PATCH] net/bridge: Add missing in6_dev_put in br_validate_ipv6
Date: Mon, 6 Jul 2015 11:35:55 +0100
Message-ID: <559A5A0B.4040700@citrix.com>
References: <1435946491-11148-1-git-send-email-julien.grall@citrix.com>
 <20150703204213.GM16529@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <stephen@networkplumber.org>, <davem@davemloft.net>,
	<bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>,
	"Bernhard Thaler" <bernhard.thaler@wvnet.at>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	<ian.campbell@citrix.com>, <wei.liu2@citrix.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150703204213.GM16529@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 03/07/15 21:42, Florian Westphal wrote:
> Julien Grall <julien.grall@citrix.com> wrote:
>> The commit efb6de9b4ba0092b2c55f6a52d16294a8a698edd "netfilter: bridge:
>> forward IPv6 fragmented packets" introduced a new function
>> br_validate_ipv6 which take a reference on the inet6 device. Although,
>> the reference is not released at the end.
>>
>> This will result to the impossibility to destroy any netdevice using
>> ipv6 and bridge.
>>
>> Spotted while trying to destroy a Xen guest on the upstream Linux:
>> "unregister_netdevice: waiting for vif1.0 to become free. Usage count = 1"
> 
> Ugh :-/
> 
> I think it makes more sense to use __in6_dev_get() instead which doesn't
> take a reference.

__in6_dev_get requires to hold rcu_read_lock or RTNL. My knowledge on
this code is very limited. Are we sure that one this lock is hold? At
first glance, I wasn't able to find one.

Regards,

-- 
Julien Grall
