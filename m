From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2] net: handle error more gracefully in socketpair()
Date: Fri, 6 Dec 2013 10:48:05 +0000
Message-ID: <20131206104805.GM10323@ZenIV.linux.org.uk>
References: <1385979146-13825-1-git-send-email-ydroneaud@opteya.com>
 <20131205.162333.1525865133149454763.davem@davemloft.net>
 <1386285331.18074.47.camel@localhost.localdomain>
 <20131205.194355.1677309681391704143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ydroneaud@opteya.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131205.194355.1677309681391704143.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 05, 2013 at 07:43:55PM -0500, David Miller wrote:
> From: Yann Droneaud <ydroneaud@opteya.com>
> Date: Fri, 06 Dec 2013 00:15:31 +0100
> 
> > AFAIK, using sys_close() seems to be the exception, and writing the file
> > descriptor before installing it is the more or less the norm.
> 
> What other system call in the kernel writes a file descriptor's value
> into the address space of a user process before the file descriptor
> is actually usable?
> 
> That's really terrible semantically.

What's the problem with that?  If nothing else, shared descriptor table is
a lot more visible to other threads than two-element array, most likely
in stack frame of whoever makes that syscall...

As for your question, how about pipe(2)?
