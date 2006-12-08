From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bug 7635] New: ioctl(fd,TCSBRK,1) on socket yields EFAULT,
 expected EINVAL/ENOTTY
Date: Fri, 8 Dec 2006 14:00:21 -0800
Message-ID: <20061208140021.27e9ab2d@freekitty>
References: <20061208095055.38fef768@localhost>
	<20061208.133633.77400985.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:42261 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1947415AbWLHWAZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:00:25 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061208.133633.77400985.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 08 Dec 2006 13:36:33 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Fri, 8 Dec 2006 09:50:55 -0800
> 
> > ioctl(TCSBRK,1)	errno
> > pty		0
> > pipe		22/EINVAL
> > /dev/null	25/ENOTTY
> > reg_file	25/ENOTTY
> > socket		14/EFAULT
> 
> If you call a TTY ioctl on a socket, it might not work, don't
> you think?
> 
> ioctl values are numbered in the namespace of the object they are
> called upon, so an ioctl of value X can mean something different for a
> TTY than it does for socket.

That is not true on BSD or other unix standardish ioctl's.
There are no conflicts between the TIOC... values and the SIOC... values

> You're passing a garbage pointer to whatever socket ioctl happens
> to be aliased to the same value as TCSBRK on your platform.

It's not the garbage pointer. 

Seems like one of those annoying standards compliance test
return value bugs that shouldn't really hit an application.
-- 
Stephen Hemminger <shemminger@osdl.org>
