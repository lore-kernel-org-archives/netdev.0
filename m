From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Shrink struct dst_entry a bit
Date: Tue, 13 Mar 2007 15:10:41 +0100
Message-ID: <200703131510.41651.dada1@cosmosbay.com>
References: <200703131448.15193.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:41283 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030308AbXCMOKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 10:10:34 -0400
In-Reply-To: <200703131448.15193.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 March 2007 14:48, Andi Kleen wrote:
> The ICMP rate limiting state can be shorts, we don't send that many ICMPs.
> Changing flags to short and reorder fields to be sorted by size to avoid
> holes. Move cold fields towards the end.
>

Nope, you cannot break the reordering I've done one month ago.

http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.22.git;a=commit;h=1e19e02ca0c5e33ea73a25127dbe6c3b8fcaac4b


[NET]: Reorder fields of struct dst_entry

This last patch (but not least :) ) finally moves the next pointer at
the end of struct dst_entry. This permits to perform route cache
lookups with a minimal cost of one cache line per entry, instead of
two.

Both 32bits and 64bits platforms benefit from this new layout.

