From: Kis-Szabo Andras <kisza@pannongsm.hu>
Subject: Re: net/ipv6/exthdrs.c
Date: 19 Jun 2002 11:30:39 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <1024478965.882.2.camel@arwen>
References: <200206181903.XAA13710@sex.inr.ac.ru>
	<1024435482.1332.10.camel@arwen>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <1024435482.1332.10.camel@arwen>
List-Id: netdev.vger.kernel.org


Hello,

> > Is there any plan to add the ESP header to the ipv6_ext_hdr() function (as a
> > known header)?
> No, ESP is not a normal extension header, it terminates parse.
> So, ipv6_skip_headers cannot skip it.
The same behaviour as in NONE, but the NONE is listed and the ESP is
not. (But it is not a problem to me, I just asked something :) )

> BTW the same is with netfilter. I do not see how are you going to use it. :-)
The ESP belongs to the headers, it is a member of a possible chain.
- header match - i had to search for the ESP, too
- ESP match - it has a public SPI value, which can be used in rules
- general iteration, skipped together with the NONE.
It terminates the header chain, but the existance of the ESP header and
its SPI value are usefull information.

> > (It requires changes in this file and in the icmp.c at the first round.)
> I am afraid this will simply break the function.
Yes, i am afraid You're right. :(
Adding the ESP to the headers will break the icmp code. :(

> This may be right even not depending on this issue. Goals are different:
> the function in exthdrs.c does the best efforts to guess what protocol
> is, the function in netfilter should be paranoid.
I added a similar function (exactly the same but with the ESP) to decide
about the nexthdr value and a new header parser/evaluator with strict
size/pointer checks.
Last week one of our user sent a direct request to eliminate the
duplicated functions - so He pushed me to send the original question to
this forum.

Thanks for the answers, I 'wrote up them'.

Regards,

	kisza

-- 
    Andras Kis-Szabo       Security Development, Design and Audit
-------------------------/        Zorp, NetFilter and IPv6
 kisza@SecurityAudit.hu /-----Member of the BUTE-MIS-SEARCHlab------>
