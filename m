From: rick jones <rick.jones2@hp.com>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same yes?
Date: Sat, 22 Jan 2005 11:05:25 -0800
Message-ID: <92ADD7B5-6CA8-11D9-86F8-000393765F60@hp.com>
References: <41F1516D.5010101@hp.com> <200501211358.53783.jdmason@us.ibm.com> <41F163AD.5070400@hp.com> <20050121124441.76cbbfb9.davem@davemloft.net> <41F17B7E.2020002@hp.com> <20050121141820.7d59a2d1.davem@davemloft.net> <41F186A8.9030805@hp.com> <20050121204948.034b2510.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050121204948.034b2510.davem@davemloft.net>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Jan 21, 2005, at 8:49 PM, David S. Miller wrote:
> The code can potentially get really messy and ugly if we start
> preemptively building larger frames "hoping" the cwnd will be
> large enough by the time we push it onto the wire.  Segmenting
> at send time is completely upside down to the way packets are
> built currently for transmission.  A bad guess also means that
> we'll spend significant cycles chopping up TSO packets and
> resegmenting the queue.

so if i'm parsing correctly, with TSO enabled, at user send time, the 
send code builds "tso-sized" segments based on the value of cwnd at the 
time of the send.

with TSO disabled, at user send time, the code will build a string of 
MSS-sized segments and queue them.

then at transmit time, cwnd is consulted and either a group of 
mss-sized segments is sent, or a tso-sized segment is sent down the 
stack.

is it necessary to build TSO-sized segments at the time the user does 
the send? could just a chain of mss-sized segments be used as the 
TSO-sized segment?

admittedly, it is more buffers to manipulate by the NIC, and the large 
DMA's don't happen, but it means that TSO can take full advantage of 
cwnd at transmit time without much resegmentation.

rick jones
there is no rest for the wicked, yet the virtuous have no pillows
