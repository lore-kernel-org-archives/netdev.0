From: Ben Greear <greearb@candelatech.com>
Subject: Re: Fw: Network driver test suite?
Date: Wed, 12 Jan 2005 10:15:34 -0800
Message-ID: <41E56946.2050503@candelatech.com>
References: <20050105152635.290ad9c0@dxpl.pdx.osdl.net>	 <1105493554.28674.49.camel@bullpen.pdx.osdl.net>	 <1105547064.5940.5.camel@dhollis-lnx.centricconsulting.com> <1105550041.28674.53.camel@bullpen.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Hollis <dhollis@davehollis.com>, netdev@oss.sgi.com,
        cliff white <cliffw@osdl.org>, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Craig Thomas <craiger@osdl.org>
In-Reply-To: <1105550041.28674.53.camel@bullpen.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Craig Thomas wrote:
> On Wed, 2005-01-12 at 08:24, David Hollis wrote:
> 
>>On Tue, 2005-01-11 at 17:32 -0800, Craig Thomas wrote:
>>
>>
>>>Would there be a desire for someone to collect the tests or at least
>>>create an index to all their locations?  If so, then developers can
>>>scan a library of potential tests to run against newly developed code.
>>>
>>>OSDL can start incorporating some of these tests into their test
>>>platform as well.
>>
>>I would love to see a collection of the types of tests that should be
>>performed.  As it appears now, there is nothing defined that a driver
>>author should do to verify that their driver performs properly, or
>>supports the right capabilities etc.  Some things may be difficult to
>>automate, but simply having a checklist would be great.  For the things
>>that can be automated, that would be even better.
> 
> 
> Great.  We can do some of this.  I would like to ask, what mimimal
> types of tests do you expect to execute for a driver?  If several
> can respond to the types of testing they perform, we can start
> a checklist.  Then, additional items can be added to fill in the
> holes.  I've asked Cliff White of OSDL to help put this together.

My wishlist includes:

set and verify all supported link speeds (auto-negotiate, 10Mbps fixed, 100Mbps fixed,
1Gbps, full/half duplex, etc)
set & verify various MTUs

At each speed, generate maximum amount of packets:
    tx only
    rx only
    tx + rx
    Could use pktgen for this as it does not ARP or do other protocol things
    would complicate rx-only and tx-only testing.
    Could also do randomized packet sizes or step through a bunch of different
    sizes.
    Could randomize rates and other things with pktgen as well.
    Determine number of dropped & errored packets at each phase.
      This should be verified by counting the number of packets transmitted
      v/s received and coorelated against any drop/error counters that the
      driver reports.

Generate TCP & UDP traffic at various speeds to make sure it handles
protocols correctly too.

Run a similar battery of tests against 802.1Q VLANS on the
interfaces in question.


I have a proprietary tool and some GPL kernel patches that can do most of this.
A bash/perl script utilizing ethtool and and pktgen (especially a version of
pktgen similar to the one in my patches which also receives packets and reports
statistics on them) and a few other tcp & udp generating tools could also do
this (and in a more transparent manner, probably.)

Please contact me off the list if you want to discuss free use of the
proprietary tool.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
