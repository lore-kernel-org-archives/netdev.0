From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 6/6] fs: Introduce kern_mount_special() to mount
	special vfs
Date: Thu, 27 Nov 2008 04:53:21 -0500
Message-ID: <20081127095321.GE13860@infradead.org>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDCAB.1070204@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	kernel-testers@vger.kernel.org, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:44546 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbYK0Jx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 04:53:27 -0500
Content-Disposition: inline
In-Reply-To: <492DDCAB.1070204@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 27, 2008 at 12:32:59AM +0100, Eric Dumazet wrote:
> This function arms a flag (MNT_SPECIAL) on the vfs, to avoid
> refcounting on permanent system vfs.
> Use this function for sockets, pipes, anonymous fds.

special is not a useful name for a flag, by definition everything that
needs a flag is special compared to the version that doesn't need a
flag.

The general idea of skippign the writer counts makes sense, but please
give it a descriptive name that explains the not unmountable thing.
And please kill your kern_mount wrapper and just set the flag manually.

Also I think it should be a superblock flag, not a mount flag as you
don't want thse to differ for multiple mounts of the same filesystem.

