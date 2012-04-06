From: Arvid Brodin <arvid.brodin@enea.com>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Fri, 6 Apr 2012 19:08:03 +0200
Message-ID: <4F7F22F3.7060402@enea.com>
References: <20120404165559.5223ab95@s6510.linuxnetplumber.net>	<20120404.202109.2046106039992811660.davem@davemloft.net>	<4F7F10FC.3020308@enea.com> <20120406.124344.564538802640968013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <shemminger@vyatta.com>, <netdev@vger.kernel.org>,
	<balferreira@googlemail.com>, <arvid.brodin@xdin.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:23551 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752439Ab2DFRIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 13:08:13 -0400
In-Reply-To: <20120406.124344.564538802640968013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Arvid Brodin <arvid.brodin@enea.com>
> Date: Fri, 6 Apr 2012 17:51:24 +0200
> 
>> Just out of curiosity, what's the mechanism behind this inline
>> assignment that turns the memcpy into an unaligned access? If gcc is 
>> "smart" enough to detect a bunch of char * accesses and turn them 
>> into unaligned 32-bit accesses, isn't that a bug in gcc?
> 
> It's not doing it with "char *", it's doing it with other types like
> the type of the ICMP header in this case.
> 
> memcpy is expanded by the compiler internally into __builtin_memcpy()
> which if it sees the length is reasonably short will inline the
> copy.  And subsequently it uses the alignment of the types involved
> to determine what kinds of loads and stores it can use in that
> inline memcpy().
> 
> So the result is that just because in your case with your compiler
> it doesn't get expanded inline and fault, it doesn't mean it won't
> for someone else.
> 
> You're just lucky, and you really haven't fixed the bug.
> 

Ok. And thanks for the explanation. Would something like this do the 
trick then?

+		/* Need to cast to (char *) below to keep gcc optimizations 
+		   from causing alignment faults. */
+		memcpy(&icmp_param.data.icmph, (char *) icmp_hdr(skb),
+						sizeof(icmp_param.data.icmph));

If not, any suggestions on how to tackle this?

-- 
Arvid Brodin
Enea Services Stockholm AB - since February 16 a part of Xdin in the Alten
Group. Soon we will be working under the common brand Xdin. Read more at
www.xdin.com.
