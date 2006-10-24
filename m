From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: How to grab a block of binary data w/out using ioctls?
Date: Mon, 23 Oct 2006 21:54:48 -0700
Message-ID: <20061023215448.f4f6c95a.randy.dunlap@oracle.com>
References: <453D61E8.8020400@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:4781 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1752028AbWJXExM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 00:53:12 -0400
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <453D61E8.8020400@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Oct 2006 17:44:24 -0700 Ben Greear wrote:

> Since IOCTLs are out of favor these days, what would be
> a preferred way to get a block of binary data out of the
> kernel?
> 
> I just want to grab a stats structure (well-aligned 32 and 64-bit counters
> and fixed-length strings) for a pktgen interface.
> 
> Can you do this with seq-files somehow?

seq-files just use printk() for text output.  Not well-suited
to binary output.

Similarly, sysfs is desirable in some circumstances, but
not for blocks of binary data.

ioctls or netlink or debugfs or relay output (see how blktrace
uses relay output) are your choices (I may have missed some. :)
ioctls can be OK for some purposes.  If you want to avoid them,
try debugfs or relay.  (I haven't looked at debugfs very much;
it may be more text-oriented also...)

---
~Randy
