From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Enabling ethernet drivers to return FCS in the skb?
Date: Sun, 23 Nov 2003 01:02:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC077B1.1050807@candelatech.com>
References: <3FB94311.10004@candelatech.com> <20031119123556.A7622@sygehus.dk> <3FBB8D61.6010106@candelatech.com> <20031120173404.A1538@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031120173404.A1538@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rask Ingemann Lambertsen wrote:
> On Wed, Nov 19, 2003 at 07:33:53AM -0800, Ben Greear wrote:
> 
>>Rask Ingemann Lambertsen wrote:
>>
>>>The Intel i82586 and i82596 and can be told to receive frames with a bad FCS.
>>>They can also be told to send a precomputed FCS rather than computing it on
>>>the fly. The i82596 and tulip can also transfer the FCS to memory when
>>>receiving frames. I guess all of this is also supported on the i82557/8/9.
>>
>>If you have a patch or example code that shows how to do this, I'd love to
>>see it.  I have code that should RX bad CSUM from the Intel folks, but I can't
>>get it to generate bad CRC (it does framing errors instead with my attempt),
>>so I can't test the RX code properly!
> 
> 
> The i825xx Ethernet chips are configured by putting a configure command on
> the TX list. One of the bits of the configure command tells the chip to
> discard or keep packets with errors. Assuming you can find that piece of
> code, flipping the bit is easy enough. Similiarily for transferring the FCS
> to/from memory. IIRC, this is a per-frame setting for TX on i82596 and
> i82557/8/9. You can find i82596 documentation on Intel's home page and
> the i82557/8/9 on SourceForge under the e100 (or was it e1000?) project.

Thanks, I found the e100 document (from sourceforge) and it looks like it can
definately receive all sorts of busted packets with a little configuration.

It's less clear what happens when you turn off the FCS generation.  One part of
the document mentions it gets it from RAM, which I assume means it uses the last
part of the DMA'd packet???  Another explanation of the transmit state machine does
not mention that you can disable FCS generation...  I'm going to print this out
and read it again in detail...

I searched Intel's site for the e1000 docs, but could not find any detailed
information.  Does anyone have a link to a (legal) copy of the e1000 docs?

Thanks for the detailed information.  When I get the e100 and e1000 working to
my satisfaction, I'll work on the tulip driver a bit.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
