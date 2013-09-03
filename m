From: Michele Baldessari <michele@acksyn.org>
Subject: Re: [PATCH] ipv6: fix null pointer dereference in __ip6addrlbl_add
Date: Tue, 3 Sep 2013 09:04:25 +0100
Message-ID: <20130903080425.GB2990@marquez.int.rhx>
References: <20130902213128.GB14301@marquez.int.rhx>
 <20130903001331.GA8820@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palahniuk.acksyn.org ([5.9.7.26]:36605 "EHLO
	palahniuk.acksyn.org" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753584Ab3ICIE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 04:04:28 -0400
Content-Disposition: inline
In-Reply-To: <20130903001331.GA8820@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

On Tue, Sep 03, 2013 at 02:13:31AM +0200, Hannes Frederic Sowa wrote:
> On Mon, Sep 02, 2013 at 10:31:28PM +0100, Michele Baldessari wrote:
> > with the latest linux master git tree from Linus
> > (248d296d6d9df384996c2ed95676b367d876d48c - 2 Sep) I can reproduceably oops 
> > the kernel with the following commands:
> > ip addrlabel flush
> > ip addrlabel add prefix ::1/128              label 0
> > ip addrlabel add prefix ::/0                 label 1
> 
> Thanks for the report! This patch should fix this issue:
> 
> [PATCH] ipv6: fix null pointer dereference in __ip6addrlbl_add
> 
> Commit b67bfe0d42cac56c512dd5da4b1b347a23f4b70a ("hlist: drop
> the node parameter from iterators") changed the behavior of
> hlist_for_each_entry_safe to leave the p argument NULL.
> 
> Fix this up by tracking the last argument.
> 
> Reported-by: Michele Baldessari <michele@acksyn.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks for the patch, fixes it for me. 

Tested-by: Michele Baldessari <michele@acksyn.org>
