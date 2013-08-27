From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH] tipc: set sk_err correctly when connection fails
Date: Tue, 27 Aug 2013 17:18:41 +0200
Message-ID: <20130827151841.GE1939@eerihug-hybrid.rnd.ki.sw.ericsson.se>
References: <1377266200-26691-1-git-send-email-erik.hugne@ericsson.com>
 <521CA797.2010109@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <tipc-discussion@lists.sourceforge.net>,
	<nhan.tt.vo@dektech.com.au>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg20.ericsson.net ([193.180.251.56]:65423 "EHLO
	sesbmg20.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570Ab3H0PSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 11:18:44 -0400
Content-Disposition: inline
In-Reply-To: <521CA797.2010109@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 27, 2013 at 09:20:23AM -0400, Paul Gortmaker wrote:
> What was the high level user visible symptom in this case?
> Stalled connections or ... ?

Should the connect fail, if the publication/server is unavailable or some other
error. The connect() call returns the error code directly (as a positive value).

[...]
socket(0x1e /* PF_??? */, SOCK_SEQPACKET, 0) = 3
setsockopt(3, 0x10f /* SOL_?? */, 129, [0], 4) = 0
setsockopt(3, 0x10f /* SOL_?? */, 127, [0], 4) = 0
connect(3, {sa_family=0x1e /* AF_??? */, sa_data="\2\1\322\4\0\0\322\4\0\0\0\0\0\0"}, 16) = 111
sendto(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 66000, 0, NULL, 0) = -1 EPIPE (Broken pipe)

In the strace above, error checking was done as:
if (connect(fd,.....) < 0)
    perror("connect");

//E
