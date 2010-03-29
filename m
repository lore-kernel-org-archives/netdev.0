From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Network performance - iperf
Date: Mon, 29 Mar 2010 09:57:33 -0700
Message-ID: <4BB0DBFD.30904@hp.com>
References: <4BB09021.6020202@petalogix.com> <4BB0D9A1.3090107@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org, Grant Likely <grant.likely@secretlab.ca>,
	John Linn <John.Linn@xilinx.com>,
	"Steven J. Magnani" <steve@digidescorp.com>,
	Arnd Bergmann <arnd@arndb.de>, akpm@linux-foundation.org
To: michal.simek@petalogix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BB0D9A1.3090107@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> I don't know how to set fixed socket buffer sizes in iperf, if you were 
> running netperf though I would suggest fixing the socket buffer sizes 
> with the test-specific -s (affects local) and -S (affects remote) options:
> 
> netperf -t TCP_STREAM -H <remote> -l 30 -- -s 32K -S 32K -m 32K
> 
> to test the hypothesis that the autotuning of the socket buffers/window 
> size is allowing the windows to grow in the larger memory cases beyond 
> what the TLB in your processor is comfortable with.

BTW, by default, netperf will allocate a "ring" of send buffers - the number 
allocated will be one more than the socket buffer size divided by the send size 
- so in the example above, there will be two 32KB buffers allocated in netperf's 
send ring.  A similar calculation may happen on the receive side.

That can be controlled via the global (before the "--") -W option.

     -W send,recv      Set the number of send,recv buffers

So, you might make the netperf command:

netperf -t TCP_STREAM -H <remote> -l 30 -W 1,1 -- -s 32K -S 32K -m 32K

happy benchmarking,

rick jones
