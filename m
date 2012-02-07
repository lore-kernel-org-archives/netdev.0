From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v3 2/2] Implement IPV6_UNICAST_IF socket option.
Date: Mon, 06 Feb 2012 22:00:05 -0500
Message-ID: <4F3093B5.5070801@hp.com>
References: <1328551064-28573-2-git-send-email-ehoover@mines.edu>	<4F30428B.2080102@hp.com> <CAEU2+vr823WcoF_Z4NV7ptWNBQ4uTG+tD2VAXbQPDYGqsaKpLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:48151 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755638Ab2BGDAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 22:00:07 -0500
In-Reply-To: <CAEU2+vr823WcoF_Z4NV7ptWNBQ4uTG+tD2VAXbQPDYGqsaKpLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2012 05:11 PM, Erich E. Hoover wrote:
> On Mon, Feb 6, 2012 at 2:13 PM, Brian Haley <brian.haley@hp.com> wrote:
>> On 02/06/2012 12:57 PM, Erich E. Hoover wrote:
>>> ...
>>> +     int                     outif_index;
>> ...
>> Nitpick: is ucast_oif a better name?
> 
> I templated off of the IPv4 code (example: mc_index), but I do think
> that that is a better name.  Should I call the IPv4 version
> "ucast_index" or have the same name for both IPv4 and IPv6?

If it was me I'd call it uc_index for IPv4, to mimic mc_ifindex.

>>> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
>>> index 01d46bf..18f144e 100644
>>> --- a/net/ipv6/icmp.c
>>> +++ b/net/ipv6/icmp.c
>>> @@ -551,6 +551,9 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
>>>               return;
>>>       np = inet6_sk(sk);
>>>
>>> +     if (!fl6.flowi6_oif)
>>> +             fl6.flowi6_oif = ipv6_default_ifindex(sk);
>>> +
>>>       if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
>>>               fl6.flowi6_oif = np->mcast_oif;
>>
>> This snippet shows (and rawv6_sendmsg() has the same problem), that
>> IPV6_UNICAST_IF can also affect multicast packets.  And I think we always want
>> SO_BINDTODEVICE to override them all.  Perhaps these checks should be:
>> ...
> 
> I'll double check all of these tonight, but a cursory look seems to
> indicate that the multicast check is the right place to put this for
> all the files.  I'm sorry about that, I clearly didn't consider
> interfering with multicast.

It's probably important to keep the precedence the same as before:

	SO_BINDTODEVICE
	IPV6_PKTINFO
	IPV6_*CAST_IF

It looks like your IPv4 changes have the same problem.

-Brian
