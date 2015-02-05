From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH] rds: Make rds_message_copy_from_user() return 0 on
 success.
Date: Thu, 5 Feb 2015 17:07:34 -0500
Message-ID: <20150205220734.GC28883@oracle.com>
References: <20150205202050.GH5811@oracle.com>
 <20150205215845.GT29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150205215845.GT29656@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (02/05/15 21:58), Al Viro wrote:
> *blink*
> 
> Commit 083735f4b0 ("rds: switch rds_message_copy_from_user() to iov_iter"),
> surely?  That's the one that touches copy-from side of things...
> 
> And unlike the previous commit (the one you'd mentioned) here the return value
> of copy_page_....() ended up passed to caller of its caller.  Mea culpa.
> 
> So, modulo correction of the commit message,
> 
> Acked-by: Al Viro <viro@zeniv.linux.org.uk>

That was the one that git-bisect flagged for me.. I think this one
had the iov_iter_init() in rds_sendmsg() itself? As I recall, this 
change was already refactoring rds_message_copy_from_user() (and was the
earliest version that was broken when I tested it)?

should it have been 'put iov_iter into msghdr'? I just wanted
to make sure some innocent user would know how far back to go,
if they wanted to not trip on this one.

--Sowmini
