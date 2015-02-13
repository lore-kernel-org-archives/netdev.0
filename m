From: Imre Palik <imrep.amz@gmail.com>
Subject: Re: [PATCH] bridge: make it possible for packets to traverse the
 bridge withour hitting netfilter
Date: Fri, 13 Feb 2015 17:08:20 +0100
Message-ID: <54DE2174.6040001@gmail.com>
References: <1423560744-19011-1-git-send-email-imrep.amz@gmail.com> <20150211.142936.951620487173949333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	imrep@amazon.de, aliguori@amazon.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150211.142936.951620487173949333.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/11/15 23:29, David Miller wrote:
> From: Imre Palik <imrep.amz@gmail.com>
> Date: Tue, 10 Feb 2015 10:32:24 +0100
> 
>> From: "Palik, Imre" <imrep@amazon.de>
>>
>> The netfilter code is made with flexibility instead of performance in mind.
>> So when all we want is to pass packets between different interfaces, the
>> performance penalty of hitting netfilter code can be considerable, even when
>> all the firewalling is disabled for the bridge.
>>
>> This change makes it possible to disable netfilter both on a per bridge basis,
>> or for the whole bridging subsystem.  In the case interesting to us, this can
>> lead to more than 10% speedup compared to the case when only bridge-iptables
>> are disabled.
>>
>> Cc: Anthony Liguori <aliguori@amazon.com>
>> Signed-off-by: Imre Palik <imrep@amazon.de>
> 
> Sorry, no.
> 
> If I apply this, someone is going to try to submit a patch for every
> damn protocol layer to add a stupid hack like this.

Actually this is one of those patches.  There is already a "stupid hack like this" for iptables and arptables.  (Implemented before git history, and giving me 10% speedup.  Many thanks, whoever did it.)

I also searched various LKML archives, and it seems the existing "stupid hacks" for iptables and arptables haven't resulted in any related patch submission in the last ten years.  (Or my google-fu is weak.)

Moreover, I cannot imagine any other reasonable on/off switch for bridge-netfilter than these three.  Of course, my imagination might be lacking there.

> Makw NF_HOOK() faster instead.

As far as I see, flexibility implies trashing the cache/TLB.  So it is impossible to have flexibility and performance at the same time.
(Except possibly with self modifying code, but that has its own set of problems.)
