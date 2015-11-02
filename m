From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Mon, 2 Nov 2015 10:29:23 +0000
Message-ID: <20151102102923.GR22011@ZenIV.linux.org.uk>
References: <20151019095938.72ea48e6@xeon-e3>
 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
 <562594E1.8040403@oracle.com>
 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151021034950.GL22011@ZenIV.linux.org.uk>
 <5627A37B.4090208@oracle.com>
 <20151021185104.GM22011@ZenIV.linux.org.uk>
 <201510212033.t9LKX4G8007718@room101.nl.oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBC8782@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Casper.Dik@oracle.com'" <Casper.Dik@oracle.com>,
	Alan Burlison <Alan.Burlison@oracle.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dholland-tech@netbsd.org" <dholland-tech@netbsd.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54788 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbbKBK3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 05:29:34 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBC8782@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 02, 2015 at 10:03:58AM +0000, David Laight wrote:
> Remember, Solaris (and SYSV) has extra levels of multiplexing between
> userspace and char special drivers (and probably sockets) than Linux does.
> As well as having multiple fd referencing the same struct FILE, multiple
> FILE can point to the same inode.

As they ever could on any Unix.  Every open(2) results in a new struct file
(BTW, I've never seen that capitalization for kernel structure - not in
v7, not in *BSD, etc.; FILE is a userland typedef and I would be rather
surprised if any kernel, Solaris included, would've renamed 'struct file'
to 'struct FILE').

> If you have two different /dev entries for the same major/minor you
> also end up with separate inodes - all finally referencing the same
> driver data (indexed only by minor number).

Again, the same goes for all Unices, both Linux and Solaris included.
And what the devil does that have to do with sockets, anyway?  Or with
the problem in question, while we are at it - they have different
descriptors pointing to the same struct file behave differently;
anything sensitive to file type would be past that point.
