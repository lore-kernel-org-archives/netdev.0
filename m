From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/4] NFS: Support raw IPv6 address hostnames during NFS
	mount operation
Date: Sun, 18 May 2008 18:23:40 -0400
Message-ID: <1211149420.18810.11.camel@localhost>
References: <20080518210625.13450.71349.stgit@ellison.1015granger.net>
	 <20080518212011.13450.77551.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:45128 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752598AbYERWXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2008 18:23:44 -0400
In-Reply-To: <20080518212011.13450.77551.stgit@ellison.1015granger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-05-18 at 17:20 -0400, Chuck Lever wrote:
> Traditionally the mount command has looked for a ":" to separate the
> server's hostname from the export path in the mounted on device name,
> like this:
> 
> 	mount server:/export /mounted/on/dir
> 
> The server's hostname is "server" and the export path is "/export".
> 
> You can also substitute a specific IPv4 network address for the server
> hostname, like this:
> 
> 	mount 192.168.0.55:/export /mounted/on/dir
> 
> Raw IPv6 addresses present a problem, however, because they look
> something like this:
> 
> 	fe80::200:5aff:fe00:30b
> 
> Note the use of colons.
> 
> To get around the presence of colons, copy the Solaris convention used for
> mounting IPv6 servers by address: wrap a raw IPv6 address with square
> brackets.

Standardising is good, so we should definitely support any pre-existing
Solaris conventions. However is there any reason why we couldn't use the
sequence ':/' as the separator for the IP address and the pathname for
cases where we're in doubt?

In other words, if it turns out that 'fe80' is the actual hostname, and
':200:5aff:fe00:30b' is the root pathname component, then is there any
reason why 'mount.nfs' couldn't reformat that as
'fe80:/:200:5aff:fe00:30b'?

Cheers
  Trond

