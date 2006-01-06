From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Fri, 06 Jan 2006 14:45:12 +0000
Message-ID: <1136558713.30498.21.camel@localhost.localdomain>
References: <20060105235845.967478000@sorel.sous-sol.org>
	 <20060106004555.GD25207@sorel.sous-sol.org>
	 <Pine.LNX.4.64.0601051727070.3169@g5.osdl.org>
	 <43BE43B6.3010105@cosmosbay.com>
	 <1136554632.30498.7.camel@localhost.localdomain>
	 <43BE77F1.4090301@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Dipankar Sarma <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751451AbWAFOqa@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <43BE77F1.4090301@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Gwe, 2006-01-06 at 15:00 +0100, Eric Dumazet wrote:
> In the case of call_rcu_bh(), you can be sure that the caller cannot afford 
> 'sleeping memory allocations'. Better drop a frame than block the stack, no ?

atomic allocations can't sleep and will fail which is fine. If memory
allocation pressure exists for sleeping allocations because of a large
rcu backlog we want to be sure that the rcu backlog from the networking
stack or other sources does not cause us to OOM kill or take incorrect
action.

So if for example we want to grow a process stack and the memory is
there just stuck in the RCU lists pending recovery we want to let the
RCU recovery happen before making drastic decisions.
