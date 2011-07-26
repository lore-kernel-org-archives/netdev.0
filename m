From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] vfs: dont chain pipe/anon/socket on superblock s_inodes
 list
Date: Tue, 26 Jul 2011 07:49:06 -0400
Message-ID: <20110726114906.GA19975@infradead.org>
References: <20110723132411.GA22183@infradead.org>
 <1311633550.2576.33.camel@schen9-DESK>
 <20110725225154.GD22133@ZenIV.linux.org.uk>
 <1311636178.2576.34.camel@schen9-DESK>
 <1311660013.2996.6.camel@edumazet-laptop>
 <1311668466.2355.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20110726090357.GA13013@infradead.org>
 <1311672994.2355.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20110726094204.GA12086@infradead.org>
 <1311677013.2355.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Anton Blanchard <anton@samba.org>, npiggin@kernel.dk,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1311677013.2355.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 26, 2011 at 12:43:33PM +0200, Eric Dumazet wrote:
> BTW, we have one atomic op that could be avoided in new_inode()
> 
> spin_lock(&inode->i_lock);
> inode->i_state = 0;
> spin_unlock(&inode->i_lock);
> 
> can probably be changed to something less expensive...
> 
> inode->i_state = 0;
> smp_wmb();
> 
> Not clear if we really need a memory barrier either....

I think we already had this in some of the earlier vfs/inode scale
series, but it got lost when Al asked to just put the fundamental
changes in.

For plain new_inode() the barrier shouldn't be needed as we take
the sb list lock just a little later.  I'm not sure about your new
variant, so I'll rather lave that to you.

There's a few other things missing from earlier iterations, most notable
the non-atomic i_count, and the bucket locks for the inode hash, if
you're eager enough to look into that area.

