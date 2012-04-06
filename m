From: Arvid Brodin <arvid.brodin@enea.com>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Fri, 6 Apr 2012 17:51:24 +0200
Message-ID: <4F7F10FC.3020308@enea.com>
References: <20120403113751.21fd0b17@s6510.linuxnetplumber.net>	<4F7CD4BC.4000006@enea.com>	<20120404165559.5223ab95@s6510.linuxnetplumber.net> <20120404.202109.2046106039992811660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <shemminger@vyatta.com>, <netdev@vger.kernel.org>,
	<balferreira@googlemail.com>, <arvid.brodin@xdin.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:18823 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754168Ab2DFPvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 11:51:35 -0400
In-Reply-To: <20120404.202109.2046106039992811660.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 4 Apr 2012 16:55:59 -0700
> 
>> That isn't so bad, doing a memcpy versus a structure copy.
> 
> GCC is going to inline the memcpy and thus we'll still do the
> unaligned accesses.  This change therefore won't fix the problem.

Well, it does work for me, with gcc-4.2.2-compiled linux-2.6.37 running
on an AVR32 board.

Just out of curiosity, what's the mechanism behind this inline
assignment that turns the memcpy into an unaligned access? If gcc is 
"smart" enough to detect a bunch of char * accesses and turn them 
into unaligned 32-bit accesses, isn't that a bug in gcc?

Or will this only happen on archs which __HAVE_ARCH_MEMCPY? (But looking
at a couple of arch/xxx/lib/string.c, these too seem to take alignment
into account.)

-- 
Arvid Brodin
Enea Services Stockholm AB - since February 16 a part of Xdin in the Alten
Group. Soon we will be working under the common brand Xdin. Read more at
www.xdin.com.
