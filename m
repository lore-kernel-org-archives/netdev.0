From: "David S. Miller" <davem@davemloft.net>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same
 yes?
Date: Fri, 21 Jan 2005 12:44:41 -0800
Message-ID: <20050121124441.76cbbfb9.davem@davemloft.net>
References: <41F1516D.5010101@hp.com>
	<200501211358.53783.jdmason@us.ibm.com>
	<41F163AD.5070400@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <41F163AD.5070400@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 Jan 2005 12:18:53 -0800
Rick Jones <rick.jones2@hp.com> wrote:

> This is with tcp_tso_win_divisor set to 1 so TSO kicks-in before 200some-oddK 
> are transfered.   The service demand drop (modulo the accuracy of CPU util 
> measurements via the -DUSE_PROC_STAT stuff) is rather nice.

Don't set tcp_tso_win_divisor to such a low value, that's why
TCP is being so bursty in your case.  The default value
of "8" keeps TCP reasonable well ACK clocked, thus avoiding
the throughput lossage you are seeing with it set to "1".

With a value of "1", TCP will wait for the entire congestion
window to be ACK'd before it will spit out a huge TSO frame.
