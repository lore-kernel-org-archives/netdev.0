From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [SECURITY] Fix leaking of kernel heap addresses via /proc
Date: Sat, 06 Nov 2010 16:11:47 -0400
Message-ID: <1289074307.3090.100.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org
To: chas@cmf.nrl.navy.mil, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:58725 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702Ab0KFULu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Nov 2010 16:11:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maintainers,

I am planning on submitting a series of patches to resolve the leakage
of kernel heap addresses to userspace via network protocol /proc
interfaces.  Revealing this information is a bad idea from a security
perspective for a number of reasons, the most obvious of which is it
provides unprivileged users a mechanism by which to create a structure
in the kernel heap containing function pointers, obtain the address of
that structure, and overwrite those function pointers by leveraging
other vulnerabilities.  It is my hope that by eliminating this
information leakage, in conjunction with making statically-declared
function pointer tables read-only (to be done in a separate patch
series), we can at least add a small hurdle for the exploitation of a
subset of kernel vulnerabilities.

Here's the list of protocols that I've identified as leaking socket
structure addresses via their /proc interfaces:

atm
ipv4
ipv6
key
netlink
packet
phonet
unix

There may be others, and I will continue looking for more examples, but
this is at least a good start.

Clearly, in most cases we cannot just remove the field from the /proc
output, as this would break a number of userspace programs that rely on
consistency.  However, I propose that we replace the address with a "0"
rather than leaking this information.

I'm writing this email before submitting a patch to ask if anyone would
have any objections to this change, and if anyone can foresee anything
breaking as a result of this.  Please let me know if you're on board,
have some doubts, or are totally opposed, and I can get this patch ready
for submission.

Thanks,
Dan Rosenberg

