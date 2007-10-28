From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [PATCH] proc_fs.h redux
Date: Sun, 28 Oct 2007 10:34:15 +0000
Message-ID: <20071028103415.GA12554@flint.arm.linux.org.uk>
References: <20071027194758.GD9816@martell.zuzino.mipt.ru> <1193524804.26695.103.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>, akpm@osdl.org,
	torvalds@osdl.org, viro@zeniv.linux.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arch@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:44252 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbXJ1Kjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 06:39:53 -0400
Content-Disposition: inline
In-Reply-To: <1193524804.26695.103.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 27, 2007 at 03:40:04PM -0700, Joe Perches wrote:
> and forward declarations of
> 
> struct proc_dir_entry;
> struct file_operations;
> 
> As a general rule, I think it better to use includes
> than use naked forward declarations.

If you go down that route, you end up with _lots_ of circular
dependencies - header file X needs Y needs Z which needs X.  We've
been there, several times.  It very quickly becomes quite
unmaintainable - you end up with hard to predict behaviour from
include files.

The only realistic solution is to use forward declarations.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:
