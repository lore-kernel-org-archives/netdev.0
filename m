From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 0/4] RFC: raw IPv6 address parsing in NFS client
Date: Mon, 19 May 2008 16:32:36 -0400
Message-ID: <4831E3E4.5060700@hp.com>
References: <20080518210625.13450.71349.stgit@ellison.1015granger.net> <4830E24C.3020405@garzik.org> <BA7B3AE0-E0BA-4535-8641-5DC4A3A41F64@oracle.com> <4831CD54.9050004@garzik.org> <7799EF8C-6BDB-4B32-ABD8-E3DF840D5195@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:28162 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbYESUci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 16:32:38 -0400
In-Reply-To: <7799EF8C-6BDB-4B32-ABD8-E3DF840D5195@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Lever wrote:
>>>> 2) an interface name rather than index should be used
>>> If you give a raw IPv6 address with an interface name to mount.nfs, 
>>> it passes the whole thing to getaddrinfo(3) which maps the name to an 
>>> index. The address with index is then passed on to the kernel via 
>>> mount(2) via the normal "addr=" mount option.
>>> Is there a way the kernel can do that mapping for itself?
>>
>> The kernel certainly knows the interface names...  IMO that is a bit 
>> more natural than interface index.
>>
>> You certainly do not want to _store_ interface index or encourage its 
>> use, since it might change during runtime if network interfaces change.
> 
> We are storing the address of the server in a struct sockaddr_storage, 
> and that would include a scope ID if it were an AF_INET6 address.  We 
> are also storing the server hostname in /etc/mtab for umount.nfs to use 
> later, and that hostname may be a raw IPv6 address.
> 
> So it sounds like we need to store the device name separately in the 
> kernel's NFS and RPC data structures and do the devname to scope_id 
> conversion during the transport's socket connect.  Oy.

Hmm, the kernel already stores interface indexes in structures today, 
for example if you use SO_BINDTODEVICE, or join a Multicast group. 
Seems to me that's perfectly valid to do, with the caveat that the 
device might change it's index.

-Brian
