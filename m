From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: IPv6: presentation format for zero scope ID
Date: Tue, 8 Dec 2009 11:08:01 -0500
Message-ID: <2146C217-21C6-4F38-B056-EDCD40E3DE1D@oracle.com>
References: <EA6985CB-3B58-4982-85FE-94C951D2FE5E@oracle.com> <4B1DC794.5020406@hp.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>,
	Jeff Layton <jlayton@redhat.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:28193 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932433AbZLHQJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 11:09:25 -0500
In-Reply-To: <4B1DC794.5020406@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 7, 2009, at 10:27 PM, Brian Haley wrote:
> Chuck Lever wrote:
>> I recently added some functions to sunrpc.ko that behave like
>> getnameinfo(AI_NUMERICHOST) does in user space.
>>
>> One of the functions, rpc_ntop6(), sticks a scope ID on the end of  
>> link-
>> and site-local IPv6 addresses.  It does not try to map the scope ID  
>> to a
>> device name.
>
> Site-local addresses have been deprecated...
>
>> It has been pointed out, however, that glibc's getnameinfo(3) skips
>> appending a device name if the scope ID is zero.  Should rpc_ntop6()
>> display or ignore zero scope IDs?
>
> A zero scope id implies it's not set, so I would ignore it.  Things  
> like
> *bind() and *connect() already do this.
>
>> Would it be better if it also
>> converted scope IDs to device names?
>
> *nix typically uses %eth0, Windows uses %1, so I guess if it's for
> display purposes I'd do the same thing all the tools use - %name.
> This isn't being put in a packet, is it?

RPC uses presentation format addresses for lots of things.  Such a  
presentation address will go on the wire in the form of a universal  
address.  uaddrs were around before scope IDs were invented, so they  
don't support or use the %n or %dev notation.  Naturally the scope ID  
doesn't have meaning for other systems anyway.

Such an address can also be used for RPC cache upcalls to user space  
daemons.  A scope ID would potentially have meaning in that case.

So it sounds like it would be reasonable to:

a) squelch appending "%n" if n is zero, and

b) append a device name instead of an integer scope ID

>> I'm not familiar enough with the IETF mandates regarding presentation
>> address format, or the idiosyncrasies of the Linux IPv6  
>> implementation,
>> to know what is the desired behavior here.  Any guidance appreciated.
>
> The URI spec (RFC 3986) doesn't cover scope id's, so it winds-up being
> implementor's choice.
>
> -Brian

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



