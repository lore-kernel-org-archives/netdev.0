From: Andras Kis-Szabo <kisza@securityaudit.hu>
Subject: Re: [Patch]: IPv6 Connection Tracking
Date: 25 Sep 2003 20:48:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064515680.995.41.camel@localhost>
References: <200309250521.OAA29293@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netfilter Devel <netfilter-devel@lists.netfilter.org>,
        Netdev <netdev@oss.sgi.com>, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
In-Reply-To: <200309250521.OAA29293@toshiba.co.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dear Yasuyuki,

I have some questions against the code.
The first question is about the extension headers.
I have used an own 'external header skipper' routine which was very
close the the kernel's one. So I would like to update the netfilter code
to use the kernel's function. For this, we have to export the
ipv6_skip_exthdr() function from net/ipv6/exthdrs.c . I have checked
your code, too. It looks very close to the kernel's code.
As I have noticed, the differences:
- handling of the fragments
  your code checks that the member of the extension are in the skb or
not since the common part checks only the basic extension header size.
After it your code linearizes the skb to cover the extension header.
So, the kernel does not check the size and does not linearize. After
these fixes the 2 codes will be similar.
Would not be better to export the kernel's function and use the
ipv6_skip_exthdr() in the netfilter codes?

My second commet is near this area. I have planned that an offset value
which points after the last extension header and a variable which
contain the last nexthdr value would be very helpful for the future -
but I was too lazy to do this work. With the connection tracking this
function (ipv6_skip_exthdr) will be called several time on the same
packet (in the main kernel, at every LOG, at every match, at every ct,
...) With USAGI we could - probably - find the space for this 2
variable. Do you have any recommendation?

Your FTP code uses EPSV and EPRT from rfc2428. What's about the FOOBAR
RFC (1639)? OK, it's a joke :)
Could we open an IPv4 data connection next to the IPv6 controll
connection?

Regards,

	kisza

-- 
    Andras Kis-Szabo       Security Development, Design and Audit
-------------------------/        Zorp, NetFilter and IPv6
 kisza@SecurityAudit.hu /------------------------------------------->
