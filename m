From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] rxrpc: Miscellaneous fixes
Date: Fri, 16 Sep 2016 01:55:10 -0400 (EDT)
Message-ID: <20160916.015510.564823888003392258.davem@davemloft.net>
References: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35140 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751062AbcIPFzN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 01:55:13 -0400
In-Reply-To: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Tue, 13 Sep 2016 23:20:56 +0100

> 
> Here's a set of miscellaneous fix patches.  There are a couple of points of
> note:
> 
>  (1) There is one non-fix patch that adjusts the call ref tracking
>      tracepoint to make kernel API-held refs on calls more obvious.  This
>      is a prerequisite for the patch that fixes prealloc refcounting.
> 
>  (2) The final patch alters how jumbo packets that partially exceed the
>      receive window are handled.  Previously, space was being left in the
>      Rx buffer for them, but this significantly hurts performance as the Rx
>      window can't be increased to match the OpenAFS Tx window size.
> 
>      Instead, the excess subpackets are discarded and an EXCEEDS_WINDOW ACK
>      is generated for the first.  To avoid the problem of someone trying to
>      run the kernel out of space by feeding the kernel a series of
>      overlapping maximal jumbo packets, we stop allowing jumbo packets on a
>      call if we encounter more than three jumbo packets with duplicate or
>      excessive subpackets.
 ...
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20160913-1

Pulled, thanks David.
