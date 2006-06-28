From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Network namespaces a path to mergable code.
Date: Tue, 27 Jun 2006 22:33:48 -0600
Message-ID: <m1ac7xkifn.fsf@ebiederm.dsl.xmission.com>
References: <20060626134945.A28942@castle.nmd.msu.ru>
	<m14py6ldlj.fsf@ebiederm.dsl.xmission.com>
	<20060627215859.A20679@castle.nmd.msu.ru>
	<44A1AF37.3070100@vilain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Savochkin <saw@swsoft.com>, dlezcano@fr.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, herbert@13thfloor.at,
	devel@openvz.org, viro@ftp.linux.org.uk,
	Alexey Kuznetsov <alexey@sw.ru>,
	Mark Huang <mlhuang@CS.Princeton.EDU>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:16333 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S1030371AbWF1EfY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 00:35:24 -0400
To: Sam Vilain <sam@vilain.net>
In-Reply-To: <44A1AF37.3070100@vilain.net> (Sam Vilain's message of "Wed, 28
	Jun 2006 10:20:39 +1200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sam Vilain <sam@vilain.net> writes:

> It sounds then like it would be a good start to have general socket
> namespaces, if it would merge more easily - perhaps then network device
> namespaces would fall into place more easily.


I guess I really see both sockets and devices as the fundamental
entities of a network namespace.  Sockets need to be tagged because
in the general case there is no guarantee that a socket that you are
using was created in the network namespace of your current process.

In general it is possible to get file descriptors opened by someone
else because unix domain sockets allow file descriptor passing.  Similarly
I think there are cases in both unshare and fork that allows you to sockets
open before you entered a namespace.

Since you can't create a new socket in a different network namespace
I can't see any real problems with allowing them to be used, but they
are something to be careful about in container creation code.

Something to examine here is that if both network devices and sockets
are tagged does that still allow implicit network namespace passing.

Eric
