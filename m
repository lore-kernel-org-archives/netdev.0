From: Joshua Kinard <kumba@gentoo.org>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Tue, 27 Dec 2011 16:29:57 -0500
Message-ID: <4EFA38D5.1000602@gentoo.org>
References: <4EED3A3D.9080503@gentoo.org> <4EF95247.7000403@gentoo.org> <20111227103408.01aad10e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linux MIPS List <linux-mips@linux-mips.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:49945
	"EHLO qmta12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751342Ab1L0VaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 16:30:13 -0500
In-Reply-To: <20111227103408.01aad10e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/27/2011 13:34, Stephen Hemminger wrote:

> On Tue, 27 Dec 2011 00:06:15 -0500
> Joshua Kinard <kumba@gentoo.org> wrote:
> 
>> @@ -95,7 +95,7 @@ struct mace_video {
>>   * Ethernet interface
>>   */
>>  struct mace_ethernet {
>> -	volatile unsigned long mac_ctrl;
>> +	volatile u64 mac_ctrl;
>>  	volatile unsigned long int_stat;
>>  	volatile unsigned long dma_ctrl;
>>  	volatile unsigned long timer;
> 
> 
> This device driver writer needs to read:
>   Documentation/volatile-considered-harmful.txt

MIPS I/O registers are always memory-mapped, and to prevent the compiler
from trying to over-optimize, volatile is used to make sure we always read a
value from the hardware and not from some cached value.

See MIPS Run (2nd Ed), pp 307, section 10.5.2 highlights an example of this,
which is viewable here:
http://books.google.com/books?id=kk8G2gK4Tw8C&pg=PA307&lpg=PA308#v=onepage&q&f=false

But other than that, yeah, this driver needs to pretty much be stripped down
to the nuts and bolts and re-written.  Maybe something to tackle in the
future.  I still haven't gotten around to submitting the RTC driver for O2's
(that I re-wrote from a patch sent into LKML years ago) upstream yet.

-- 
Joshua Kinard
Gentoo/MIPS
kumba@gentoo.org
4096R/D25D95E3 2011-03-28

"The past tempts us, the present confuses us, the future frightens us.  And
our lives slip away, moment by moment, lost in that vast, terrible in-between."

--Emperor Turhan, Centauri Republic
