From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  e100: Enable receiving bogus packets, and transmitting
 bad/custom CRC
Date: Sat, 13 Dec 2003 11:12:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FDB64B1.5050700@candelatech.com>
References: <3FC2931B.3070903@candelatech.com> <20031213200044.B1791@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031213200044.B1791@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rask Ingemann Lambertsen wrote:
> On Mon, Nov 24, 2003 at 03:24:11PM -0800, Ben Greear wrote:
> 
>>Thanks to those who pointed me in the right direction, here is a patch
>>to the e100 (2.4.23-pre9) that allows it to capture all frames, bogons included.
>>It also coppies the FCS to the skb so ethereal et al can read it.
>>
>>It utilizes ethtool commands to get/set the rx-all feature, and uses
>>a new flag in the skbuff (and socket struct) structure to determine when to disable generating
>>the FCS on transmit.  I have the entire patch that adds the management
>>bits and flags, but as usual, it's mixed in with various other things...
> 
> 
> Reading the tulip manual (see below) triggered a question: When transmitting
> a custom CRC, who is responsible for padding the frame to the minimum length?
> If frame padding is left to the driver, what should be used for padding?

Hrm, I have not tested this, as my sending app itself enforces the minimum
size.  I am guessing that padding is up to the driver/OS in this case,
but I'd have to re-read the e100 docs to be sure...

> I (or rather, Google) found the tulip documentation at
> <URL:http://www.intel.com/design/network/manuals/278074.htm>. The tulip
> chips are capable of all these tricks too.

Cool, I'll check out this doc soon.  If you happen to write up a tulip driver
patch for this feature, please let me know.  I have lots of 4-port tulip nics to
test on here...

DaveM:  Are you interested in getting these patches into 2.4.24-preX?  (It would
be helpful to get the infrastructure and ethtool portions in, even if the driver
parts remain outside the tree for a bit longer.)


Thanks,
Ben

> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
