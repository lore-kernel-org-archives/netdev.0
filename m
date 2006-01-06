From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Fri, 06 Jan 2006 13:37:12 +0000
Message-ID: <1136554632.30498.7.camel@localhost.localdomain>
References: <20060105235845.967478000@sorel.sous-sol.org>
	 <20060106004555.GD25207@sorel.sous-sol.org>
	 <Pine.LNX.4.64.0601051727070.3169@g5.osdl.org>
	 <43BE43B6.3010105@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Dipankar Sarma <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932405AbWAFNgy@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <43BE43B6.3010105@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Gwe, 2006-01-06 at 11:17 +0100, Eric Dumazet wrote:
> I assume that if a CPU queued 10.000 items in its RCU queue, then the oldest 
> entry cannot still be in use by another CPU. This might sounds as a violation 
> of RCU rules, (I'm not an RCU expert) but seems quite reasonable.

Fixing the real problem in the routing code would be the real fix. 

The underlying problem of RCU and memory usage could be solved more
safely by making sure that the sleeping memory allocator path always
waits until at least one RCU cleanup has occurred after it fails an
allocation before it starts trying harder. That ought to also naturally
throttle memory consumers more in the situation which is the right
behaviour.

Alan
