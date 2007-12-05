From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] don't allow netfilter --setmss to increase mss
Date: Wed, 05 Dec 2007 09:37:14 +0100
Message-ID: <4756633A.8010201@trash.net>
References: <20071204224535.GY27007@kvack.org> <47565F64.2000907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47565F64.2000907@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Benjamin LaHaise wrote:
>> Yes, I am aware of --clamp-mss-to-pmtu, but it doesn't work for 
>> outgoing connections from clients (ie web traffic), as it only looks 
>> at the PMTU on the destination route, not the source of the packet 
>> (the DSL interfaces in question have a 1442 byte MTU while the 
>> destination ethernet interface is 1500 -- there are problematic hosts 
>> which use a 1300 byte MTU).  Reworking that is probably a good idea at 
>> some point, but it's more work than this is.
> 
> Yes, this has always annoyed me too as it doesn't really work for me
> in a similar setup where traffic first goes through an IPsec tunnel,
> then through a MSS mangling gateway and then over a DSL line. I'll
> add a patch on top of yours to take the MSS in reverse direction
> into account.


This gets a bit too ugly because of rp-filters and actually might
not properly work in setups with routing by fwmark, so I'll leave
it as it is, its probably better to manually set the MSS in these
cases.

