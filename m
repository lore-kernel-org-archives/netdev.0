From: Peter Bieringer <pb@bieringer.de>
Subject: Re: ip6tables: accept of IPv6 transport esp packages not possible -
 no rule matches
Date: Sun, 02 Jan 2005 13:15:42 +0100
Message-ID: <E7944B8AE7C7468F39D3C2F8@worker.muc.bieringer.de>
References: <019064D0423CE6C823CBF476@t1mobil.muc.aerasec.de>
 <5F6ACA5CEF52DBFBF11FBF94@t1mobil.muc.aerasec.de>
 <41CD8B4F.6010402@trash.net>
 <85346B5DA83795C08812E782@worker.muc.bieringer.de>
 <41D7DE3E.2090304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: USAGI core <usagi-core@linux-ipv6.org>,
        Maillist netdev <netdev@oss.sgi.com>,
        Harald Welte <laforge@gnumonks.org>,
        Netfilter development mailing list <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41D7DE3E.2090304@trash.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Sunday, January 02, 2005 12:42:54 PM +0100 Patrick McHardy
<kaber@trash.net> wrote:

>> But I wonder a little bit because of the result of the OUTPUT chain:
>> 
>>     0     0 ACCEPT     icmpv6    *      *       ::/0                 ::/0
>> ipv6-icmp type 129
>>     1   104 ACCEPT     icmpv6    *      *       ::/0                 ::/0
>> ipv6-icmp type 128
>>     0     0 ACCEPT     esp      *      *       local/128  remote/128
>>     0     0 ACCEPT     all      *      *       local/128  remote/128
>> 
>> 
>> Here, the ICMPv6 rule matches.
>> 
>> This means for me that the traffic goes like this:
>> 
>> OUTPUT: ping6 -> netfilter -> encryption -> ESP
>> INPUT : ESP -> netfilter -> decryption -> ping6
> 
> More specific, with transport mode it goes:
> 
> OUTPUT: ping6 -> LOCAL_OUT -> encryption -> POST_ROUTING
> INPUT: ESP -> PRE_ROUTING -> LOCAL_IN -> decryption -> ping6
> 
> Filtering for IPv6 happens on LOCAL_IN/LOCAL_OUT (and FORWARD).
> 
>> Is this logical?
> 
> Not very. Patches to improve this for IPv4 will be submitted
> next week, but IPv6 still needs some work.
> 
>> 
>> BTW: how to filter incoming traffic after decryption?
> 
> Use tunnel-mode. The decrypted packets will hit PRE_ROUTING
> and LOCAL_IN again.

Ok, confirmed working in tunnel mode, ping6 packet was counted twice in
different rules (esp and icmpv6)

But for outgoing ping6 packets, this won't work, packet is only counted
(and accepted) by the icmpv6 rule, esp rule got no match, also not the
"all" rule.

Looks like at the moment, outgoing packet is passing netfilter only one
time, even if encryption is in tunnel mode.

By design / bug / missing feature?

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
