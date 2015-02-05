From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] rds: Make rds_message_copy_from_user() return 0 on
 success.
Date: Thu, 5 Feb 2015 22:23:01 +0000
Message-ID: <20150205222301.GU29656@ZenIV.linux.org.uk>
References: <20150205202050.GH5811@oracle.com>
 <20150205215845.GT29656@ZenIV.linux.org.uk>
 <20150205220734.GC28883@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150205220734.GC28883@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 05, 2015 at 05:07:34PM -0500, Sowmini Varadhan wrote:

> That was the one that git-bisect flagged for me.. I think this one
> had the iov_iter_init() in rds_sendmsg() itself?

No, it doesn't - it only touches recvmsg side of things.

> As I recall, this 
> change was already refactoring rds_message_copy_from_user() (and was the
> earliest version that was broken when I tested it)?
> 
> should it have been 'put iov_iter into msghdr'? I just wanted
> to make sure some innocent user would know how far back to go,
> if they wanted to not trip on this one.

Look at your own patch; it affects only sendmsg() path, as does
"rds: switch rds_message_copy_from_user() to iov_iter".  In fact, the code
it fixes had been introduced in that commit.  I agree that the bug is
there and I agree with your fix; the only problem I have is your interpretation
of bisect.  "rds: switch ->inc_copy_to_user() to passing iov_iter" is
the last one *not* to have that particular breakage.

Seriously, reread both commits and your fix:
"rds: switch ->inc_copy_to_user() to passing iov_iter" - only recvmsg side
"rds: switch rds_message_copy_from_user() to iov_iter" - only sendmsg side
your fix to rds_message_copy_from_user() - only sendmsg side
