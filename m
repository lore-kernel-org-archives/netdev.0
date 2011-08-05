From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Fw: [Bug 39132] Starting with 3.0.0-rc6, masquerading seems to
 be broken.
Date: Fri, 5 Aug 2011 18:16:43 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108051744480.29588@ja.ssi.bg>
References: <20110804193107.68d93727@schatten.dmk.lab> <alpine.LFD.2.00.1108042131040.1495@ja.ssi.bg> <8A188C9C23A54337A5A276BAE29DC6E0@delorimier>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Florian Mickler <florian@mickler.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	bugzilla-daemon@bugzilla.kernel.org
To: David Hill <hilld@binarystorm.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:33709 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753817Ab1HEPPP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2011 11:15:15 -0400
In-Reply-To: <8A188C9C23A54337A5A276BAE29DC6E0@delorimier>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 5 Aug 2011, David Hill wrote:

>    I'm not using TPROXY and I've used a blank firewall with only masquerading
> and reproduced the issue.
> Nothing is in NAT/mangle nor OUTPUT  but the rules mentionned in the attached
> files to this bug.
> 
> Francis Whittle  (Comment #18) has the same issue.

	I compiled 3.0 kernel, added one -j MASQUERADE and
tried TCP connection - it works. I'm not sure ip_route_me_harder
is called for masqueraded traffic, usually it is called
from LOCAL_OUT handlers or to send TCP RST (-j REJECT) via
LOCAL_OUT, not for forwarded traffic.

	Can you show lines of tcpdump output with addresses and
ports, so that I can understand what kind of traffic is
dropped, is it initial forwarded packet or its response,
is it problem with some ICMP packets, I assume there is
no problem with locally generated traffic.

	Can you show output from:

# grep . /proc/sys/net/ipv4/conf/*/rp_filter
# grep . /proc/sys/net/ipv4/conf/*/send_redirects

	If it works with -rc5 it should not be rp_filter,
for NAT, problem can be with ICMP redirects or something else.
Can you tell us if the internal and external devices are
same or may be many.

Regards

--
Julian Anastasov <ja@ssi.bg>
