From: Jon Grimm <jgrimm2@us.ibm.com>
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Mon, 13 Jan 2003 17:34:12 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E234CF4.70309@us.ibm.com>
References: <200301132125.AAA09366@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, davem@redhat.com, sri@us.ibm.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> 
>>So in short clearing DF is near always a bug these days.
> 
> 
> Exactly. And it is exactly why I said that this compromises all the pmtu
> discvoery and why I would like people consulted SCTP designers before
> doing this step. I cannot believe that new protocol was designed in this way.
> 
> Alexey
> 

It is indeed designed this way.  http://www.ietf.org/rfc/rfc2960.txt 
section 7.3 discusses the differences in SCTP PMTU discovery versus RFC 
1191.

SCTP packets are filled with "chunks".  Data records can be broken into 
multiple chunks.  Chunks are then "bundled" into the packet.

Once a TSN (Transmission Sequence Number) is assigned to a data fragment 
(chunk) of a record, it can not be further fragmented.  This should be a 
rare occurance, but can happen when PMTU shrinks.

Now, that being said, there is an alternative that I originally alluded 
to.  That is, pre-fragment chunks down to the smallest possible MTU's 
needs and then bundle the chunks up together to satisfy the current 
PMTU.   If the current PMTU shrinks, bundle in fewer chunks, down to the 
smallest packet containing a single chunk.   There is a little extra 
processing at each end and each chunk within the packet eats up a chunk 
header of 4 bytes.


Best Regards,
Jon
