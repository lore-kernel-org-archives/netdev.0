From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 1 Aug 2003 16:19:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030801161937.1d9a7126.davem@redhat.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>
	<20030801154021.GA7696@gtf.org>
	<20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>
	<20030801162536.GA18574@gtf.org>
	<20030801132037.3f3542ae.davem@redhat.com>
	<3F2AE91D.5090705@pobox.com>
	<20030801153255.204baf66.davem@redhat.com>
	<3F2AF141.2010308@pobox.com>
	<20030801160136.3342c5cc.davem@redhat.com>
	<3F2AF525.3000605@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F2AF525.3000605@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 01 Aug 2003 19:17:57 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Solution #2 chooses to create a tiny bit more 
> merge-to-mainline pain, but also keeps the mainline kernel drivers more 
> clean.

You don't need DO_ETHTOOL_OPS and thus the merge-to-mainline pain
at all if you do something like:

1) SET_ETHDEV_OPS() also overrides the ->do_ioctl() setting to
   a kcompat_netdev_ioctl() one, but remembers the original pointer
   somewhere.

2) kcompat_netdev_ioctl() does the things DO_ETHTOOL_OPS would
   have done, failing that it calls the saved ->do_ioctl() pointer.
