From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] proc: proc_create() should return true if CONFIG_PROC_FS is not configured
Date: Wed, 25 Feb 2015 11:19:20 +0000
Message-ID: <15346.1424863160@warthog.procyon.org.uk>
References: <CAPFHKzcLsL9Sb_ma4_XCm4a0kX_iNcCdFVXf346wtnmOPqWcEg@mail.gmail.com> <1424841259-8470-1-git-send-email-zhangzl2013@126.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, Zhang Zhaolong <zhangzl2013@126.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	viro@zeniv.linux.org.uk
To: Jonathon Reinhart <jonathon.reinhart@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49400 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753371AbbBYLTd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 06:19:33 -0500
In-Reply-To: <CAPFHKzcLsL9Sb_ma4_XCm4a0kX_iNcCdFVXf346wtnmOPqWcEg@mail.gmail.com>
Content-ID: <15345.1424863160.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathon Reinhart <jonathon.reinhart@gmail.com> wrote:

> Does that even compile? proc_create() and proc_create_data() both return
> "struct proc_dir_entry *". It doesn't make sense for those macros to "return"
> anything but NULL - certainly not 1.
> 
> Besides, why shouldn't "if (!proc_create())" behave like proc_create()
> failed when
> CONFIG_PROC_FS is not enabled?  You wouldn't want the caller to start trying
> to use that ((struct proc_dir_entry *)1) would you?

It's sort of arguable.  If the proc interface is merely informational and
doesn't impact the function of a module to not be present, then, yes, having
proc_create() return some "true" value might make sense.  It's possible to
arrange things so that all the proc-related functions and data get compiled
out in such a situation by not being referenced by anything.

However, if the proc interface isn't merely functional, then the proc_create()
failure *is* cause for module loading failure.  But in that case, there should
be a Kconfig dependency on procfs and you should never use the dummy
functions.

David
