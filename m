From: "David S. Miller" <davem@redhat.com>
Subject: Re: BUG or not? GFP_KERNEL with interrupts disabled.
Date: Thu, 27 Mar 2003 11:10:12 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030327.111012.23672715.davem@redhat.com>
References: <Pine.LNX.4.33.0303271315010.30532-100000@dane-linux.aiinet.com>
	<Pine.LNX.4.44.0303271104270.31459-100000@home.transmeta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dane@aiinet.com, shmulik.hen@intel.com,
   bonding-devel@lists.sourceforge.net, bonding-announce@lists.sourceforge.net,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
   mingo@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: torvalds@transmeta.com
In-Reply-To: <Pine.LNX.4.44.0303271104270.31459-100000@home.transmeta.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Linus Torvalds <torvalds@transmeta.com>
   Date: Thu, 27 Mar 2003 11:08:26 -0800 (PST)

   So what the test SHOULD look like is this:
   
   	if (gfp_mask & __GFP_WAIT) {
   		if (in_atomic() || irqs_disabled()) {
   			static int count = 0;
   			...
   		}
   	}
   
   which should catch all the cases we really care about.

Let's codify this "in_atomic() || irqs_disabled()" test into a macro
that everyone can use to test sleepability, ok?
