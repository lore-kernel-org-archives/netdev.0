From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 00/10] The rest of the FIB patches (add
 key_vector to fib_table)
Date: Fri, 06 Mar 2015 15:52:05 -0500 (EST)
Message-ID: <20150306.155205.1495845027833807835.davem@davemloft.net>
References: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932092AbbCFUwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 15:52:08 -0500
In-Reply-To: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Fri, 06 Mar 2015 09:53:49 -0800

> This patch series is the rest of what I had originally planned for this kernel
> release.  It adds a structure called key_vector which is embedded within
> every tnode, leaf, and the trie root itself.  By doing this we can navigate
> from any point within the trie to any other point fairly quickly and
> avoiding NULL pointer checks in the case of a backtrace.  As a result we
> can pipeline things a bit further since we don't have to worry about
> dereferencing NULL in a backtrace.  This can amount to significant savings
> on a long backtrace.
> 
> I decided to drop the up-level code as that conflicts with combining the
> main and local tries.  I have one patch as an RFC that currently combines
> the tries however it still needs some work as we have to split the local
> and main tries in the event of custom rules being defined.  As such we are
> probably going to be doing some more hacking on fib_table_flush_external as
> that will also need to flush the local entries from the main trie and place
> them back in the local trie.
> 
> v2: Rebased on the switchdev FIB offload work

Looks good, series applied, thanks Alex.
