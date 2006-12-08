From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 7635] New: ioctl(fd,TCSBRK,1) on socket yields EFAULT,
 expected EINVAL/ENOTTY
Date: Fri, 08 Dec 2006 13:36:33 -0800 (PST)
Message-ID: <20061208.133633.77400985.davem@davemloft.net>
References: <20061208095055.38fef768@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45083
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1947306AbWLHVgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 16:36:22 -0500
To: shemminger@osdl.org
In-Reply-To: <20061208095055.38fef768@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 8 Dec 2006 09:50:55 -0800

> ioctl(TCSBRK,1)	errno
> pty		0
> pipe		22/EINVAL
> /dev/null	25/ENOTTY
> reg_file	25/ENOTTY
> socket		14/EFAULT

If you call a TTY ioctl on a socket, it might not work, don't
you think?

ioctl values are numbered in the namespace of the object they are
called upon, so an ioctl of value X can mean something different for a
TTY than it does for socket.

You're passing a garbage pointer to whatever socket ioctl happens
to be aliased to the same value as TCSBRK on your platform.
