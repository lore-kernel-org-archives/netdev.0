From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [Patch]: IPv6 Connection Tracking
Date: Fri, 26 Sep 2003 12:54:21 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309260354.MAA29078@toshiba.co.jp>
References: <200309250521.OAA29293@toshiba.co.jp>
	<1064515680.995.41.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yasuyuki.kozakai@toshiba.co.jp, netfilter-devel@lists.netfilter.org,
        netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kisza@securityaudit.hu
In-Reply-To: <1064515680.995.41.camel@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi, Andras,

From: Andras Kis-Szabo <kisza@securityaudit.hu>
Subject: Re: [Patch]: IPv6 Connection Tracking
Date: 25 Sep 2003 20:48:01 +0200

kisza> I have used an own 'external header skipper' routine which was very
kisza> close the the kernel's one. So I would like to update the netfilter code
kisza> to use the kernel's function. For this, we have to export the
kisza> ipv6_skip_exthdr() function from net/ipv6/exthdrs.c . I have checked
kisza> your code, too. It looks very close to the kernel's code.
kisza> As I have noticed, the differences:
kisza> - handling of the fragments

No, ip6_ct_skip_exthdr() in my code may return NEXTHDR_NONE.
I want to distinguish the packet with NEXTHDR_NONE and the packet with unknown
extension header. I want to let "proto_generic" module to handle it.

BTW, handling of the fragments is bug fix.
"fhdr->frag_off" in ipv6_skip_exthdr() is out of area of "hdr".
I thought that it's already reported but look like still not fixed...

kisza>   your code checks that the member of the extension are in the skb or
kisza> not since the common part checks only the basic extension header size.
kisza> After it your code linearizes the skb to cover the extension header.
kisza> So, the kernel does not check the size and does not linearize. After
kisza> these fixes the 2 codes will be similar.

Excuse me, I don't understand which code you said about. find_prev_fhdr() ?
This function finds previous header of fragment header. We can't use
ipv6_skip_exthdr() to do this. Even though we can find offset of fragment
header, we can't find offset of previous header because we can't parse
extension header backwards.

kisza> Would not be better to export the kernel's function and use the
kisza> ipv6_skip_exthdr() in the netfilter codes?

I think so about ip6_ct_skip_exthdr(). I'm going to delete this function
from my patch if 

	we don't need to distinguish packets with NEXTHDR_NONE and the packet
	with unknown extension header.

and when

	the bug in ipv6_skip_exthdr() is fixed.

kisza> My second commet is near this area. I have planned that an offset value
kisza> which points after the last extension header and a variable which
kisza> contain the last nexthdr value would be very helpful for the future -
kisza> but I was too lazy to do this work. With the connection tracking this
kisza> function (ipv6_skip_exthdr) will be called several time on the same
kisza> packet (in the main kernel, at every LOG, at every match, at every ct,
kisza> ...) With USAGI we could - probably - find the space for this 2
kisza> variable. Do you have any recommendation?

I think we'd be better that extension header is parsed in L3 specific code
at once, and the offset and the nexthdr value is passed the functions
which need one as argument. This eases writing l3 independent codes in future.

kisza> Your FTP code uses EPSV and EPRT from rfc2428. What's about the FOOBAR
kisza> RFC (1639)? OK, it's a joke :)

I want to think that's joke, too...

kisza> Could we open an IPv4 data connection next to the IPv6 controll
kisza> connection?

You can't open even though you load ip_conntrack_ftp and ip6_conntrack_ftp.
I don't want to allow that because I don't know what happens.

Regards,

----------------------------------------
Yasuyuki KOZAKAI

Communication Platform Laboratory,
Corporate Research & Development Center,
Toshiba Corporation

yasuyuki.kozakai@toshiba.co.jp
----------------------------------------
