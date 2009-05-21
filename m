From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] ieee1394: eth1394: use "firewire%d" instead of "eth%d"
 as interface name
Date: Thu, 21 May 2009 23:35:38 +0200
Message-ID: <4A15C92A.9030300@s5r6.in-berlin.de>
References: <tkrat.21c425cc195510c9@s5r6.in-berlin.de>	<20090521.123403.13286908.davem@davemloft.net>	<4A15B5FE.3070207@s5r6.in-berlin.de> <20090521.133304.10307675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fenlason@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20090521.133304.10307675.davem@davemloft.net>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stefan Richter <stefanr@s5r6.in-berlin.de>
> Date: Thu, 21 May 2009 22:13:50 +0200
> 
>> But I mildly disagree with the notion that the kernel can't start off
>> with more qualification of the names than merely ensuring their
>> uniqueness.  Or the other way around: Even an entirely meaningless
>> prefix would be better than "eth..", or no prefix if that's possible,
>> because eth suspiciously sounds like Ethernet with which the misnamed
>> RFC 2734 driver eth1394 has very little to do.
> 
> Even the driver source file is named "ethXXX"!  All of the macros
> in the driver are named ETH*.  The eth1394hdr looks eerily similar
> to a real ethernet header except that it lacks a source MAC
> address.  It's addressing information plus a 16-bit (wow, why that
> size huh?) protocol field.  A lot like ethernet.

Sure, because
   1. eth1394 was initially written with an eye on how Linux Ethernet
      drivers look like (for quite a while it didn't implement RFC 2734),
   2. by nature, RFC 2734 as an IP encapsulation can't be very different
      from Ethernet.  As it happens, RFC 2734 indeed reuses a certain
      16 bits wide protocol type field in its encapsulation header, with
      familar values such as 0x0800.

[BTW, the rest of the struct eth1394hdr is not the encapsulation header 
which goes out to the wire, it's only used internally by the driver. The 
real on-the-wire headers are 20...28 bytes wide, depending on 
transaction mode and link fragmentation, and there are 4 bytes trailing 
data CRC.]
-- 
Stefan Richter
-=====-=-=== -=-= -==-=
http://arcgraph.de/sr/
