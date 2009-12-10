From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: IPv6: presentation format for zero scope ID
Date: Thu, 10 Dec 2009 13:19:08 -0500
Message-ID: <3C8ED938-D4F9-4167-BC02-575265B7A56A@oracle.com>
References: <EA6985CB-3B58-4982-85FE-94C951D2FE5E@oracle.com> <4B1DC794.5020406@hp.com> <20091208080331.3eb5ddfa@tlielax.poochiereds.net> <9E4B7973-D2C4-438C-9BF6-A35B343F2363@oracle.com> <4B2029A1.5010404@hp.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Jeff Layton <jlayton@redhat.com>,
	Linux Network Developers <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:25416 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761246AbZLJSTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 13:19:25 -0500
In-Reply-To: <4B2029A1.5010404@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 9, 2009, at 5:50 PM, Brian Haley wrote:
> Hi Chuck,
>
> Chuck Lever wrote:
>>> So this means that addresses with those prefixes should be treated  
>>> like
>>> any other address, right? If so, then I think the rpc_ntop6  
>>> shouldn't be
>>> affixing scopeid's to site local addresses.
>>
>> As a final detail, we're trying to understand what is the correct
>> treatment for site-local addresses.  I've looked at RFC 3879.  In
>> late-model Linux kernels, is Jeff's interpretation correct, for
>> application layer protocols like RPC?
>
> Not sure if this answers the question, but recent Linux kernels only  
> look
> at the scope ID for link-local addresses.

OK, I'll drop the support in net/sunrpc/addr.c for SITELOCAL.

One other thing.  This is a rather more broad question, but still IPv6- 
related.

I'm considering mapping the scope ID to a device name in rpc_ntop6(),  
but it looks like network device names are part of a net namespace,  
and these presentation address strings are shared.  This address  
string might appear in /proc/mounts, for example, but can also be used  
to send messages to user space service daemons like statd or gssd.  We  
try to do the conversion once when certain objects are created (like  
an RPC client data structure) and then save the string.

Is it OK to leave just the scope ID (for link-local only, of course),  
or might the scope IDs also vary depending on the namespace?  I  
wouldn't think that they would.

Thanks for your advice so far.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



