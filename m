From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 23:19:43 -0800
Message-ID: <20041118231943.B14339@build.pdx.osdl.net>
References: <Xine.LNX.4.44.0411180257300.3144-100000@thoron.boston.redhat.com> <Xine.LNX.4.44.0411180305060.3192-100000@thoron.boston.redhat.com> <20041118084449.Z14339@build.pdx.osdl.net> <419D6746.2020603@blueyonder.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@osdl.org>, James Morris <jmorris@redhat.com>,
	netdev@oss.sgi.com, Stephen Smalley <sds@epoch.ncsc.mil>,
	lkml <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261221AbUKSHTr@vger.kernel.org>
To: Ross Kendall Axe <ross.axe@blueyonder.co.uk>
Content-Disposition: inline
In-Reply-To: <419D6746.2020603@blueyonder.co.uk>; from ross.axe@blueyonder.co.uk on Fri, Nov 19, 2004 at 03:23:50AM +0000
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ross Kendall Axe (ross.axe@blueyonder.co.uk) wrote:
> Taking this idea further, couldn't we split unix_dgram_sendmsg into 2 
> functions, do_unix_dgram_sendmsg and do_unix_connectionless_sendmsg (and 
> similarly for unix_stream_sendmsg), then all we'd need is:
> 
> <pseudocode>
> static int do_unix_dgram_sendmsg(...);
> static int do_unix_stream_sendmsg(...);
> static int do_unix_connectionless_sendmsg(...);
> static int do_unix_connectional_sendmsg(...);

We could probably break it down to better functions and helpers, but I'm
not sure that's quite the breakdown.  That looks to me like an indirect
way to pass a flag which is already encoded in the ops and sk_type.
At anyrate, for 2.6.10 the changes should be small and obvious.
Better refactoring should be left for 2.6.11.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
