From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Fri, 11 Feb 2005 15:09:11 -0800
Message-ID: <420D3B17.3040506@us.ibm.com>
References: <0525M9211@server5.heliogroup.fr> <420D37A3.6020209@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hubert Tonneau <hubert.tonneau@fullpliant.org>,
        "David S. Miller" <davem@davemloft.net>, shemminger@osdl.org,
        romieu@fr.zoreil.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <420D37A3.6020209@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones wrote:

> 000010 10.107.96.7.32801 > 10.107.96.230.139: . 11692:13140(1448) ack 
> 822 win 1460 <nop,nop,timestamp 534449 1709240658> NBT Packet (DF)
> 000004 10.107.96.7.32801 > 10.107.96.230.139: . 13140:14588(1448) ack 
> 822 win 1460 <nop,nop,timestamp 534449 1709240658> NBT Packet (DF)
> 000002 10.107.96.7.32801 > 10.107.96.230.139: P 14588:16036(1448) ack 
> 822 win 1460 <nop,nop,timestamp 534449 1709240658> NBT Packet (DF)
> 000022 10.107.96.7.32801 > 10.107.96.230.139: . 16036:17484(1448) ack 
> 822 win 1460 <nop,nop,timestamp 534449 1709240658> NBT Packet (DF)
> 000004 10.107.96.7.32801 > 10.107.96.230.139: P 17484:18192(708) ack 822 
> win 1460 <nop,nop,timestamp 534449 1709240658> NBT Packet (DF)
> 000994 10.107.96.230.139 > 10.107.96.7.32801: . ack 18192 win 65535 
> <nop,nop,timestamp 1709240658 534449> (DF)
> 0
> 
> And then other cases where the ACK seems to take a rather long time to 
> arrive, seems to correlate a bit with slowly increasing numbers of 
> segments before the ACK is sent, and something along the lines of a 200 
> millisecond delayed ACK timer.
> 
> In some cases at least if the sender does not completely fill cwnd the 
> ACKs will be delayed.  And IIRC under 2.6.10 with TSO enabled, the 
> sender does not always fill cwnd.

Er, how is this compliant with 2581 (yes, I know, it's only
a SHOULD, not a MUST)  - an ACK should be generated for at
least every second full-sized segment received? Don't see
that happening. In many cases it's receiving quite a few
more packets. It should not be waiting for the delayed
ack timer to go off, surely?

thanks,
Nivedita
