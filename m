From: Patrick McHardy <kaber@trash.net>
Subject: Re: [v4 PATCH 1/2] NETFILTER module xt_hmark, new target 	for HASH
 based fwmark
Date: Wed, 30 Nov 2011 16:27:26 +0100
Message-ID: <4ED64B5E.2030705@trash.net>
References: <hr62jai.42522fc2b4c8846204d05566f5c6b926@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <hr62jai.42522fc2b4c8846204d05566f5c6b926@obelix.schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/28/2011 10:36 AM, Hans Schillstrom wrote:
>> If you don't want to use conntrack in your setup and you want to handle
>> fragments, then you have to configure HMARK to calculate the hashing
>> based on the network addresses. If you want to fully support fragments,
>> then enable conntrack and you can configure HMARK to calculate the
>> hashing based on network address + transport bits.
>>
>> Fix this by removing the fragmentation handling, then assume that
>> people can select between two hashing configuration for HMARK. One
>> based for network address which is fragment-safe, one that uses the
>> transport layer information, that requires conntrack. Otherwise, I
>> don't see a sane way to handle this situation.
> Correct me if I'm wrong here,
> If conntrack is enabled hmark don't see the packet until it is reassembled and
> in that case the fragmentation header is removed.
>
> So, with conntrack HMARK will operate on full packets not fragments
> without conntrack ports will not be used on any fragment

Correct.

You don't necessarily need conntrack for defragmentation though,
we've moved defragmentation to a seperate module for TPROXY. You
can depend on that and get defragmentation without full
connection tracking.


