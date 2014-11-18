From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [patches][RFC] situation with csum_and_copy_... API
Date: Tue, 18 Nov 2014 19:40:53 +0000
Message-ID: <20141118194053.GA14641@ZenIV.linux.org.uk>
References: <20141118084745.GT7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141118084745.GT7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 18, 2014 at 08:47:45AM +0000, Al Viro wrote:

> I do have a patch doing just that; the question is what to do with csum-and-copy
> primitives.  Originally I planned to simply strip those access_ok() from those
> (both the explicit calls and use of copy_from_user() where we ought to use
> __copy_from_user(), etc.), but that's not nice to potential out-of-tree callers
> of those suckers.  If any of those exist and manage to cope with the wonderful
> calling conventions, that is.  As it is, we have the total of 4 callers of
> csum_and_copy_from_user() and 2 callers of csum_and_copy_to_user(), all in
> networking code.  Do we care about potential out-of-tree users existing and
> getting screwed by such change?  Davem, Linus?

FWIW, the beginning of series in question follows; removal of those
access_ok() is 3/5.  The series is longer than that (see vfs.git#iov_iter-net
for a bit more, and there's more stuff in local queue still too much in flux
to push them out), but all the stuff relevant to validating iovecs on
sendmsg/recvmsg and getting rid of excessive access_ok() is in the first 5
commits.
