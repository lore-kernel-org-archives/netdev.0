From: Peter Bieringer <pb@bieringer.de>
Subject: Re: ip6tables: accept of IPv6 transport esp packages not possible -
 no rule matches
Date: Sun, 02 Jan 2005 10:01:20 +0100
Message-ID: <85346B5DA83795C08812E782@worker.muc.bieringer.de>
References: <019064D0423CE6C823CBF476@t1mobil.muc.aerasec.de>
 <5F6ACA5CEF52DBFBF11FBF94@t1mobil.muc.aerasec.de>
 <41CD8B4F.6010402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: USAGI core <usagi-core@linux-ipv6.org>,
        Maillist netdev <netdev@oss.sgi.com>,
        Harald Welte <laforge@gnumonks.org>,
        Netfilter development mailing list <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41CD8B4F.6010402@trash.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

--On Saturday, December 25, 2004 04:46:23 PM +0100 Patrick McHardy
<kaber@trash.net> wrote:

> Peter Bieringer wrote:
>> Looks like there is something going wrong in the protocol matching 
>> algorithm in netfilter6.
> 
> Does this patch fix the problem ?
> 
> Regards
> Patrick

Yes, this patch fix the problem on the incoming side:

I ping6 to a remote host via IPsec in transport mode:

IPv6 INPUT chain:

    0     0 ACCEPT     icmpv6    *      *       ::/0                 ::/0
ipv6-icmp type 128
    0     0 ACCEPT     icmpv6    *      *       ::/0                 ::/0
ipv6-icmp type 129
    1   156 ACCEPT     esp      *      *       remote/128  local/128
    0     0 ACCEPT     all      *      *       remote/128  local/128


So the proper chain matches.


But I wonder a little bit because of the result of the OUTPUT chain:

    0     0 ACCEPT     icmpv6    *      *       ::/0                 ::/0
ipv6-icmp type 129
    1   104 ACCEPT     icmpv6    *      *       ::/0                 ::/0
ipv6-icmp type 128
    0     0 ACCEPT     esp      *      *       local/128  remote/128
    0     0 ACCEPT     all      *      *       local/128  remote/128


Here, the ICMPv6 rule matches.

This means for me that the traffic goes like this:

OUTPUT: ping6 -> netfilter -> encryption -> ESP
INPUT : ESP -> netfilter -> decryption -> ping6

Is this logical?

BTW: how to filter incoming traffic after decryption?

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
