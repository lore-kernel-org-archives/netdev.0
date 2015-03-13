From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the vfs tree
Date: Fri, 13 Mar 2015 00:52:47 -0400 (EDT)
Message-ID: <20150313.005247.525984466584401105.davem@davemloft.net>
References: <20150313131543.7c050492@canb.auug.org.au>
	<20150312.232426.1464986797003264151.davem@davemloft.net>
	<20150313035609.GO29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, hch@lst.de, ying.xue@windriver.com,
	balbi@ti.com, stern@rowland.harvard.edu, linux-usb@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150313035609.GO29656@ZenIV.linux.org.uk>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Fri, 13 Mar 2015 03:56:09 +0000

> On Thu, Mar 12, 2015 at 11:24:26PM -0400, David Miller wrote:
>> From: Stephen Rothwell <sfr@canb.auug.org.au>
>> Date: Fri, 13 Mar 2015 13:15:43 +1100
>> 
>> > Today's linux-next merge of the net-next tree got a conflict in
>> > net/socket.c between commits 005139a14660 ("fs: remove ki_nbytes") and
>> > e9eab93cc2dc ("fs: don't allow to complete sync iocbs through
>> > aio_complete") from the vfs tree and commit 1b784140474e ("net: Remove
>> > iocb argument from sendmsg and recvmsg") from the net-next tree.
>> > 
>> > I fixed it up (mainly using the net-next version - see below) and can
>> > carry the fix as necessary (no action is required).
>> 
>> Al, how do you want to resolve this?
> 
> Hmm...  I could backmerge 1b784140474e4fc94281a49e96c67d29df0efbde into
> vfs.git#for-next, of course, but you've got quite a pile of stuff in front
> of it...  FWIW, the conflict resolution proposed by Stephen is correct;
> the question is what should go into which tree.
> 
> Actually, prereqs of the commit in question on vfs.git side are mostly
> -stable fodder; all it really needs is vfs.git#gadget and I was planning
> to send that to Linus - fixes for leaks and use-after-free in gadgetfs
> that had been there since forever, plus fixes for regression since 3.18
> (->f_op flipping that had always been fishy and outright broke when we
> started to FMODE_CAN_READ/FMODE_CAN_WRITE).  USB folks seem to be OK
> with it.  Christoph's patch isn't a regression fix, but seeing that it's
> (a) trivial and (b) ends up causing merge headache...  Maybe it would
> make sense to pull it into mainline and resolve the conflict on backmerge
> from mainline to net-next.  Linus?  I've pushed that (gadget + ki_nbytes)
> into vfs.git#for-linus-2; would you be OK with pulling that?

Push your stuff to Linus, then I'll solve all of this by merging
Linus --> net --> net-next at some point, ok?

Meanwhile Stephen's fix will carry us over until then.

THanks!
