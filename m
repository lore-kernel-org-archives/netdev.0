From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPv6 defrag question ?
Date: Thu, 08 Dec 2011 12:10:49 +0100
Message-ID: <4EE09B39.5070401@trash.net>
References: <jec613b.4edd5c40857133156bf40cef475e9234@obelix.schillstrom.com> <4ED763EA.50307@trash.net> <201112081012.13065.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans@schillstrom.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201112081012.13065.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/08/2011 10:12 AM, Hans Schillstrom wrote:
> Hi
> While testing HMARK and IPv6 with nf_defrag_ipv6 (and nf_conntrack_ipv6 loaded) I can't see the defrag ?
>
>  From what I can see nf_conntrack_reasm goes into PREROUTING with prio -400
> and HMARK in PREROUTING with prio -150
>
> I was expecting that the reasaembled packet whould reach HMARK not the fragments.
>
> (Debug print from hmark)
> HMARK() mark:489, hash:4d04eaa1, frag:1, nhoffs:30 plen:1408 (2008::10 - 1000::1)
> HMARK() mark:489, hash:4d04eaa1, frag:1, nhoffs:0  plen:86 (2008::10 - 1000::1)
>
> IPv4 do reassm. the packets not IPv6...

Yeah, IPv6 currently only passes the defragmented packet through conntrack,
then associates the conntrack information with the individual fragments and
passes those on. I'll post patches for IPv6 NAT which will change this
to behave similar to IPv4 soon.

