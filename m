From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/4] NFS: Support raw IPv6 address hostnames during NFS mount operation
Date: Mon, 19 May 2008 10:48:48 -0400
Message-ID: <378E0D10-7391-466A-BFE8-188E57A5DB25@oracle.com>
References: <20080518210625.13450.71349.stgit@ellison.1015granger.net> <20080518212011.13450.77551.stgit@ellison.1015granger.net> <1211149420.18810.11.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:31106 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754709AbYESOuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 10:50:02 -0400
In-Reply-To: <1211149420.18810.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 18, 2008, at 6:23 PM, Trond Myklebust wrote:
> On Sun, 2008-05-18 at 17:20 -0400, Chuck Lever wrote:
>> Traditionally the mount command has looked for a ":" to separate the
>> server's hostname from the export path in the mounted on device name,
>> like this:
>>
>> 	mount server:/export /mounted/on/dir
>>
>> The server's hostname is "server" and the export path is "/export".
>>
>> You can also substitute a specific IPv4 network address for the  
>> server
>> hostname, like this:
>>
>> 	mount 192.168.0.55:/export /mounted/on/dir
>>
>> Raw IPv6 addresses present a problem, however, because they look
>> something like this:
>>
>> 	fe80::200:5aff:fe00:30b
>>
>> Note the use of colons.
>>
>> To get around the presence of colons, copy the Solaris convention  
>> used for
>> mounting IPv6 servers by address: wrap a raw IPv6 address with square
>> brackets.
>
> Standardising is good, so we should definitely support any pre- 
> existing
> Solaris conventions. However is there any reason why we couldn't use  
> the
> sequence ':/' as the separator for the IP address and the pathname for
> cases where we're in doubt?

I wondered about that.  Would we ever have to mount a server where the  
pathname does not begin with a slash?  (Mac OS server over HFS+ might  
use colons instead of slashes?)

In the mount command I also add support for recognizing NFS URLs (and  
throwing a reasonable error, since we don't support them), as they  
will contain the string ":/", like this:

   nfs://servername-or-address:port/exportpath

In this case we need the brackets to distinguish a possible IPv6  
address from the colon that separates the address from the port  
number.  However, the ":/" separates the resource type from the rest  
of the string, and we would end up with the server name being "nfs"  
and the pathname being "servername-or-address:port/export".  :-)

> In other words, if it turns out that 'fe80' is the actual hostname,  
> and
> ':200:5aff:fe00:30b' is the root pathname component, then is there any
> reason why 'mount.nfs' couldn't reformat that as
> 'fe80:/:200:5aff:fe00:30b'?

That's the way it works today.  The mount command (and kernel devname  
parser) will both look for the first colon (left to right), and  
everything after that is the pathname.  So you can certainly get a  
mount command like this to work on today's code.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
