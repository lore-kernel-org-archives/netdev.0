From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: ProxyARP and IPSec
Date: Mon, 04 Sep 2006 22:12:57 -0700
Message-ID: <44FD0759.8070307@zytor.com>
References: <20060823.151424.78711856.davem@davemloft.net> <20060823231812.GA32394@ms2.inr.ac.ru> <44ECFCF1.10500@zytor.com> <44ECFD5F.6060901@zytor.com> <1156386043.7302.773.camel@tahini.andynet.net> <44ED2797.4070304@zytor.com> <20060824125046.GA25439@ms2.inr.ac.ru> <44EFCB0F.5080506@zytor.com> <17657.42254.455342.157858@localhost.localdomain> <44F9BFC2.4050001@zytor.com> <20060904222722.GA24078@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Stephen J. Bevan" <stephen@dino.dnsalias.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:12953 "EHLO
	terminus.zytor.com") by vger.kernel.org with ESMTP id S965154AbWIEFNt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 01:13:49 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060904222722.GA24078@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov wrote:
> 
> sarcasm mode is not accepted. Linux does exactly "standard tunnel-mode IPsec".
> It does not give you device to make you totally happy.
> 

The sarcasm was a commentary to the "just switch protocols then" comment.

> Probably, you are not aware that "standard IPsec tunnel device",
> if it is created:
> 
> 1. Probably, will not accept fragmented frames, because IPsec cannot
>    handle them

Now that's interesting.  If this is true, and I have every reason to 
believe you know what you're talking about, then that would seem to be a 
problem which is hard to overcome for any security gateway, regardless 
of how it's implemented in the kernel -- the data originator might be on 
a totally different host!

Furthermore, it seems to directly contradict the following statement 
from RFC 4303 section 3.3.4:

"In tunnel mode, ESP is applied to an IP packet, which may be a fragment 
of an IP datagram."

That reading seems to imply that it should handle fragments just fine. 
Similarly, RFC 4301 section 13 ("differences from RFC 2401") states:

"For tunnel mode SAs, an SG, BITS, or BITW implementation is now allowed 
to fragment packets before applying IPsec.  This applies only to IPv4. 
For IPv6 packets, only the originator is allowed to fragment them."

(consistently with the overall IPv6 architecture.)

Transport mode is different, of course.

> 2. Probably, will have undefined MTU (65536), because of 1
> 3. Probably, will screw up TCP because of 2
>    etc.
> 
> Actually, this is the reason why it is not implemented.
> It is dirty business. :-) And the person, who implements this,
> has to be really... unscrupulous. :-)

I'm clearly failing to understand where, exactly, the problems lie.  I 
would appreciate any pointers and/or clue transfusion...

	-hpa
