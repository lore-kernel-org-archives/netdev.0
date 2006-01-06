From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Fri, 6 Jan 2006 13:58:41 +0100
Message-ID: <200601061358.42344.ak@suse.de>
References: <20060105235845.967478000@sorel.sous-sol.org> <Pine.LNX.4.64.0601051727070.3169@g5.osdl.org> <43BE43B6.3010105@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Dipankar Sarma <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751483AbWAFNAI@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <43BE43B6.3010105@cosmosbay.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 06 January 2006 11:17, Eric Dumazet wrote:

>
> I assume that if a CPU queued 10.000 items in its RCU queue, then the
> oldest entry cannot still be in use by another CPU. This might sounds as a
> violation of RCU rules, (I'm not an RCU expert) but seems quite reasonable.

I don't think it's a good assumption. Another CPU might be stuck in a long 
running interrupt, and still have a reference in the code running below
the interrupt handler.

And in general letting correctness depend on magic numbers like this is 
very nasty.

-Andi
