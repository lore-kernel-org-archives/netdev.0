From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] SUNRPC: Mark buffer used for debug printks with
	__maybe_unused
Date: Wed, 20 Feb 2008 07:29:17 -0800
Message-ID: <1203521357.7181.163.camel@localhost>
References: <47BC3303.2040101@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1063 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S932560AbYBTP3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 10:29:55 -0500
In-Reply-To: <47BC3303.2040101@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-02-20 at 17:02 +0300, Pavel Emelyanov wrote:
> There are tree places, which declare the char buf[...] on the stack
> to push it later into dprintk(). Since the dprintk sometimes (if the 
> CONFIG_SYSCTL=n) becomes an empty do { } while (0) stub, these buffers
> cause gcc to produce appropriate warnings.

What about the uses in fs?

fs/lockd/svc.c:         char buf[RPC_MAX_ADDRBUFLEN];
fs/lockd/svc4proc.c:            char buf[RPC_MAX_ADDRBUFLEN];
fs/lockd/svcproc.c:             char buf[RPC_MAX_ADDRBUFLEN];
fs/nfs/callback.c:      char buf[RPC_MAX_ADDRBUFLEN];
fs/nfsd/nfsfh.c:                char buf[RPC_MAX_ADDRBUFLEN];
fs/nfsd/nfsproc.c:              char buf[RPC_MAX_ADDRBUFLEN];

Perhaps there should be a DECLARE_RPC_BUF(buf) macro?

#define DECLARE_RPC_BUF(var) char var[MAC_BUF_SIZE] __maybe_unused


