From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [v4 PATCH 1/2] NETFILTER module xt_hmark, new target
	for HASH based fwmark
Date: Thu, 1 Dec 2011 12:39:35 +0100 (CET)
Message-ID: <jec613b.2c905808e36d8b8192d285d691c5499b@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: pablo@netfilter.org, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw21.han.skanova.net ([81.236.55.21]:38847 "EHLO
	smtp-gw21.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416Ab1LALji convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 06:39:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

t: Re: [v4 PATCH 1/2] NETFILTER module xt_hmark, new target for HASH based fwmark
>
>On 12/01/2011 12:05 PM, Hans Schillstrom wrote:
>>>>> And final question, why not simply use ipv6_skip_exthdr()?
>>>> problems with fragments...
>>> So the probem is that it will return the transport layer protocol
>>> header for fragments with frag_off == 0? We also have ipv6_find_hdr()
>>> which we could modify to indicate this in the frag_off pointer.
>> ipv6_find_hdr() will do the trick with a light modification
>> What about a wrapper like:
>>
>> int __ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
>> 		  int target, unsigned short *fragoff,  int *fragflg)
>> {
>> ...
>> 		if (nexthdr == NEXTHDR_FRAGMENT) {
>> 			unsigned short _frag_off;
>> 			__be16 *fp;
>>
>> 			if (fragflg)
>> 			        fragflg = 1;
>> 			fp = skb_header_pointer(skb,
>> 						start+offsetof(struct frag_hdr,
>> 							       frag_off),
>> 						sizeof(_frag_off),
>> 						&_frag_off);
>>
>> ...
>> }
>>
>> int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
>> 		  int target, unsigned short *fragoff)
>> {
>>          return __ipv6_find_hdr(skb, offset, terget, fragoff, NULL);
>> }
>
>Hmm that would require to change all current callers. 

Nope, ipv6_find_hdr()  looks the same,
__ipv6_find_hdr() have an extra param.

> I was more thinking of unconditionally setting *frag_off in case of
>fragments, then you can initialize it to some impossible value
>like 0xffff and determine the presence of a fragment header
>based on its value after calling ipv6_find_hdr().

That's another way  :-)

Which one do you prefer ?
