From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 0/9] Fix leaking of kernel heap addresses in net/
Date: Sun, 07 Nov 2010 11:31:32 -0500
Message-ID: <1289147492.3090.137.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: chas@cmf.nrl.navy.mil, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:64241 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831Ab0KGQbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 11:31:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series resolves the leakage of kernel heap addresses to
userspace via network protocol /proc interfaces and public error
messages.  Revealing this information is a bad idea from a security
perspective for a number of reasons, the most obvious of which is it
provides unprivileged users a mechanism by which to create a structure
in the kernel heap containing function pointers, obtain the address of
that structure, and overwrite those function pointers by leveraging
other vulnerabilities.  It is my hope that by eliminating this
information leakage, in conjunction with making statically-declared
function pointer tables read-only (to be done in a separate patch
series), we can at least add a small hurdle for the exploitation of a
subset of kernel vulnerabilities.

To maintain compatibility with userspace programs relying on
consistent /proc output, the output descriptions and number of fields
are not changed.  When a unique identifier for the socket is desired,
the socket address has been replaced with the socket inode number.  When
the inode number is already present in the output, the address has been
replaced with a 0.  In these cases, the format specifier has been
changed to %d, because a %p output of 0 from kernel space is written as
"(null)", while userspace %p can only parse "(nil)".

-Dan

