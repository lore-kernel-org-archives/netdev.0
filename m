From: Jon Grimm <jgrimm2@us.ibm.com>
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Wed, 08 Jan 2003 16:48:43 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E1CAACB.5D1B82DB@us.ibm.com>
References: <Pine.LNX.4.33.0301081451110.2281-100000@dyn9-47-18-86.beaverton.ibm.com> <20030108.150638.09647984.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
> 
>    From: Sridhar Samudrala <sri@us.ibm.com>
>    Date: Wed, 8 Jan 2003 15:04:53 -0800 (PST)
> 
>    1. Add a new argument to ip_queue_xmit() to pass the value of DF bit.
>    2. Use the __unused field in skb to pass the value of DF bit.
>    3. Let SCTP call its own routine that fills in the ip header with the
>       appropriate value in the DF bit, but this duplicates most of the code
>       in ip_queue_xmit(). Also ip_options_build() needs to be exported.
> 
>    Which option do you prefer? Or can you suggest any better alternative?
> 
> Too bad there's not a 4th option, fix SCTP.  This is really broken
> that the data stream can get into a state where resegmentation cannot
> be performed.
> 
> Sigh... I guess the new argument to ip_queue_xmit() is the least
> intrusive.

I hate to mention it, but there is at least one other alternative (to
complete the picture) that is to chunk up the messages into their
smallest fragment and then bundle these chunks up to the MTU allowable
packet.  
This however does each up space in the packet for each chunk header and
require more processing at the other end to reassemble the records.  

IIRC, this is what OpenSS7s SCTP does, while the KAME SCTP manually
controls the DF bit as per Sridhar's suggestion.   There are tradeoffs
in either approach.

Best Regards,
Jon
