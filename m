From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [RFC] sh_eth: use RNC mode for R8A7790
Date: Fri, 28 Mar 2014 20:13:00 +0000
Message-ID: <5335D7CC.3070100@codethink.co.uk>
References: <1396025185-7911-1-git-send-email-ben.dooks@codethink.co.uk> <5335DDC7.8040400@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, magnus.damm@opensource.se,
	nobuhiro.iwamatsu.yj@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:42428 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753228AbaC1UNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 16:13:05 -0400
In-Reply-To: <5335DDC7.8040400@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/03/14 20:38, Sergei Shtylyov wrote:
> Hello.
>
> On 03/28/2014 07:46 PM, Ben Dooks wrote:
>
>> The current behaviour of the sh_eth driver is not to use the RNC bit
>> for the receive ring. This means that every packet recieved is not only
>> generating an IRQ but it also stops the receive ring DMA as well until
>> the driver re-enables it after unloading the packet.
>
>> This means that a number of the following errors are generated due to
>> the receive packet FIFO overflowing due to nowhere to put packets:
>
>>     net eth0: Receive FIFO Overflow
>
>> Setting the RMCR_RNC configuration has so far been tested with an NFS
>> root filesystem and the driver has not failed yet. It is not yet known
>> why this is not set for R8A779x operation
>
>     The reason is simple: it's not set on almost all 100 Mbs devices
> except SH7757 (and most recently added R7S72100), so this was a matter
> of copy-paste. I've had setting this bit on at least R-Car devices on my
> aganda for some time but couldn't get to it yet.
>
>> (Feedback on this issue or other testing is welcome)
>
>     OK, I'll try it with netperf UDP test known to generate handful of
> the aforementioned errors, when I have time.

I find the best way is to either use NFS-root or turn on all the
locking debugging, it seems to slow things down enough for the
RX FIFO to overflow.

 From a quick debug, I saw that each RX IRQ delivered one packet
from the ring buffer before requiring the hardware received to
be re-started.

So far I have not had any chance to make any speed tests, however
it has cleared off a lot of the fifo messages off my nfs-root tests
here. I've had a ring-error, but that was due to another driver
holding interrupts for far too long.

-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
