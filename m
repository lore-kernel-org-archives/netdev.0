From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: PATCH: bonding might sleep with lock held
Date: Thu, 13 May 2004 11:44:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405131844.i4DIijD3018359@death.nxdomain.ibm.com>
References: <ak@suse.de>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: Message from Andi Kleen <ak@suse.de>
   of "Thu, 13 May 2004 10:20:53 +0200." <20040513082053.GC27682@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen <ak@suse.de> wrote:
[...]
>> 	This patch replaces dev_remove_pack() with __dev_remove_pack()
>> and adds a synchronize_net() call outside the lock.  The patch is
>> against 2.6.5, but applied to 2.6.6 for me.
>
>I would rather fix bond_close to not call this with the lock hold.
>You can just move the call a few lines up. dev->close has own
>synchronization anyways and dev_remove_pack has a lock too, so this
>should be safe.

	It will race against the timers, although I don't see anything
in there offhand that would conflict.  It just feels somehow unclean to
do it without the lock.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
