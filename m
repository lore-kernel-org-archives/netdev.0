From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [RFC, PATCH] dont insert sockets/pipes dentries into dentry_hashtable.
Date: Wed, 1 Nov 2006 08:38:11 +0000
Message-ID: <20061101083811.GS29920@ftp.linux.org.uk>
References: <20061025084726.GE18364@nuim.ie> <20061025.230615.92585270.davem@davemloft.net> <200610311948.48970.dada1@cosmosbay.com> <20061031.231954.23010447.davem@davemloft.net> <454858F2.5020206@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:43410 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1423918AbWKAIiP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 03:38:15 -0500
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <454858F2.5020206@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 01, 2006 at 09:21:06AM +0100, Eric Dumazet wrote:

> And " (deleted)" is correctly added to deleted files.

The hell it will.

touch a
touch b
exec 5<a
mv b a
ls -l /proc/$$/fd/5

With your patch and without it, please.

PS: getting rid of socket dentries is a bad idea with the capital "Fuck, No".
For those who want to see where does that path lead and are attracted to
trainwrecks in general I can recommend *BSD socket handling.  They have
paid quite painfully for lack of proper vnodes.  It's simply not worth
the resulting trouble.
