From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 15:18:23 -0700
Message-ID: <428A6DAF.7040600@hp.com>
References: <m1k6lx7gkf.fsf@muc.de>	<20050517.132202.59028935.davem@davemloft.net>	<20050517202730.GA79960@muc.de>	<20050517.140245.71090021.davem@davemloft.net>	<428A613F.1020303@hp.com> <Pine.LNX.4.61.0505171501510.3184@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.61.0505171501510.3184@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arthur Kepner wrote:
> On Tue, 17 May 2005, Rick Jones wrote:
> 
> 
>>....
>>or an added heuristic of "if have reassembled N datagrams for the same
>>source/dest/protocol tuple with ID's "larger" than 'this one' since it has
>>arrived, we are probably going to wrap so might as well drop 'this one'"  for
>>some judicious and magical selection of N that may be a decent predictor of
>>wrap on top of some existing reassembly timout.
>>....
> 
> 
> How do you define "larger" in this case? A sender is free to choose 
> any ID - they can't be assumed to be montonic, for sure. 

Actually, I was ass-u-me-ing they would be monotonic, but thinking about it 
more, that doesn't really matter.  If N datagrams from that source/dest/prot 
tuple have been reassembled since the first/current frag of this datagam has 
arrived, chances are still good that the rest of the fragments of this datagram 
are toast and any subsequent fragments with a matching src/dst/prot/id would 
likely create a frankengram.

in broad handwaving terms, those N other datagrams (non-fragmented or fragmented 
and successfully reassembled or not I suspect) are a measure of just how far 
"out of order" the rest of the fragments of this datagram happen to be.  for 
some degree of "out of orderness" we can ass-u-me the datagram is toast.

chosing a strawman, if we've received 24000 datagrams from that source/dest/prot 
(perhaps even just that source) since we've started reassembling this datagram 
from that source/dest/prot, chances seem pretty good indeed that this datagram 
is toast.  a value of N even smaller than 24000 might suffice.

the devil seems to be in the accounting.

rick jones
