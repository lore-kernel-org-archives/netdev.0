From: Baruch Even <baruch@ev-en.org>
Subject: Re: [RFC] TCP congestion schedulers
Date: Mon, 21 Mar 2005 22:30:03 +0000
Message-ID: <423F4AEB.9040100@ev-en.org>
References: <421CF5E5.1060606@ev-en.org>	<20050223135732.39e62c6c.davem@davemloft.net>	<421D1E66.5090301@osdl.org>	<421D30FA.1060900@ev-en.org>	<20050225120814.5fa77b13@dxpl.pdx.osdl.net>	<20050309210442.3e9786a6.davem@davemloft.net>	<4230288F.1030202@ev-en.org>	<20050310182629.1eab09ec.davem@davemloft.net>	<20050311120054.4bbf675a@dxpl.pdx.osdl.net>	<20050311201011.360c00da.davem@davemloft.net>	<20050314151726.532af90d@dxpl.pdx.osdl.net>	<m13bur5qyo.fsf@muc.de>	<Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu> <20050321135154.0bbeae85.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Heffner <jheffner@psc.edu>, ak@muc.de, shemminger@osdl.org,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050321135154.0bbeae85.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Mon, 21 Mar 2005 16:25:56 -0500 (EST)
> John Heffner <jheffner@psc.edu> wrote:
> 
> 
>>Would you really expect a single extra indirect call per ack to have a
>>significant performance impact?  This is surprising to me.  Where does the
>>cost come from?  Replacing instruction cache lines?
> 
> Maybe not for ACK processing (that's very thick already) but
> perhaps for a lighter fast path definitely so.

According to my tests (wrapping tcp_ack with rdtsc's) it takes about 
3000 clocks to do tcp_ack() even for fast path, slow path is not much 
slower in most cases and anyway most of the time is spent either 
handling SACKs or remove packets from the transmit queue (clean_rtx).

I doubt if the extra calls by function are going to be that much of an 
issue.

Now, if I knew how to improve performance of the clean_rtx case that 
would give a boost to ack performance.

Baruch
