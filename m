From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] rds: Make rds_message_copy_from_user() return 0 on
 success.
Date: Thu, 5 Feb 2015 21:58:45 +0000
Message-ID: <20150205215845.GT29656@ZenIV.linux.org.uk>
References: <20150205202050.GH5811@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150205202050.GH5811@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 05, 2015 at 03:20:50PM -0500, Sowmini Varadhan wrote:
> 
> Commit c310e72c8992 ("rds: switch ->inc_copy_to_user() to passing iov_iter")
> breaks rds_message_copy_from_user() semantics on success, and causes it
> to return nbytes copied, when it should return 0.  This commit fixes that bug.

*blink*

Commit 083735f4b0 ("rds: switch rds_message_copy_from_user() to iov_iter"),
surely?  That's the one that touches copy-from side of things...

And unlike the previous commit (the one you'd mentioned) here the return value
of copy_page_....() ended up passed to caller of its caller.  Mea culpa.

So, modulo correction of the commit message,

Acked-by: Al Viro <viro@zeniv.linux.org.uk>
