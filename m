From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH 00/04]: VLAN vs. packet socket inconsistencies
Date: Wed, 09 Jul 2008 00:30:04 +0200
Message-ID: <4873EA6C.40408@trash.net>
References: <48733E1B.8010501@trash.net> <20080708.151233.259338088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41436 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351AbYGHWaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 18:30:11 -0400
In-Reply-To: <20080708.151233.259338088.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue, 08 Jul 2008 12:14:51 +0200
>>
>> - packet socket auxdata is only available for non-mmaped sockets.
>>    For mmaped sockets the only place to store the data is in
>>    struct tpacket_hdr, but that would break compatibility. Not sure
>>    what to do about this case.
>>     
> The mmap socket limitation is pretty serious.  It's the only
> thing holding me back from just applying these patches right now.
>
> I think we should make a new version of the tpacket_hdr structure
> anyways, in order to make it more compat-friendly.  It currently
> has "unsigned long" members and other crap.
>
> We can design this thing to be extensible quite easily, by simply
> giving it an "offset" field.  My suggestion is:
>
> 1) sed 's/tpacket_hdr/tpacket_hdr_old/'
>
> 2) Create packet socket option PACKET_NEW_TPHDR which enables
>    use of a new tpacket_hdr layout.
>
> 3) Make new tpacket_hdr which has the VLAN tag stuff as well
>    as an 'offset' field so that we can add more stuff later
>    in a backwards compat way.
>
> 4) New new tpacket_hdr layout when PACKET_NEW_TPHDR has been
>    set.

That sounds good. Userspace needs to know about the size of
the tpacket_hdr before setting the ring parameters so it can
size the ring frames appropriately for the largest packet size
it wants to receive. This means the offset field in the
tpacket_hdr is redundant, so I'll just add a getsockopt
option for getting the size. Unless we want to be able to
include only a partial tpacket_hdr, but I don't think that
would be very useful.


