From: Jiri Bohac <jbohac@suse.cz>
Subject: bonding: should rlb rx_hashtbl be reimplemented?
Date: Mon, 27 Feb 2012 18:46:09 +0100
Message-ID: <20120227174609.GC816@midget.suse.cz>
References: <20120227173400.GB816@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36038 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753612Ab2B0RqL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Feb 2012 12:46:11 -0500
Content-Disposition: inline
In-Reply-To: <20120227173400.GB816@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2012 at 06:34:00PM +0100, Jiri Bohac wrote:
> [1]: ... unless it is replaced with another value that happens to
> have the same hash -- rx_hashtbl is not a proper hash table. In
> case of a collision, the old entry is replaced by the new one.

Unrelated to this patch:

I believe that with the current implementation, if one needs to
communicate with two hosts with colliding IP addresses, RLB can't
work properly unless you renumber your network (and it will
generate an ARP storm as a side effect!).

Has anyone thought of replacing this strange hash table
implementation with a proper hash table, with colliding entries
in linked lists, some garbage collection when the hash grows too
large (configurable hash table size), etc?

Also, once the code is reworked, it could easily be made to work with
IPv6/ND in additiopn to IPv4/ARP.

I am willing to give this a try -- any thoughts?

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
