From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] printk: implement support for extended console
 drivers
Date: Thu, 30 Apr 2015 18:12:31 -0400
Message-ID: <20150430221231.GB1949@htj.duckdns.org>
References: <1430318704-32374-1-git-send-email-tj@kernel.org>
 <1430318704-32374-4-git-send-email-tj@kernel.org>
 <20150430143128.68c2295ca18f1b872876f129@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pmladek@suse.cz, davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Kay Sievers <kay@vrfy.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150430143128.68c2295ca18f1b872876f129@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Andrew.

On Thu, Apr 30, 2015 at 02:31:28PM -0700, Andrew Morton wrote:
> So if I'm understanding this correctly, the /dev/kmsg output is altered
> (different cont handling) if some console registers with CON_EXTENDED
> (and there are no such consoles yet, so the patch is a no-op).

Yeah, that's mostly right.  /dev/kmsg output already has
"continuation" flag which indicates whether a message should be
concatenated which gets triggered occassionally currently.  This would
make use of that behavior a lot more frequently.

> If correct, this seems undesirable - registration of a CON_EXTENDED
> console collaterally damages the /dev/kmsg interface?  If the user has
> an app which depends on the original /dev/kmsg format then they'll be
> wondered what-the-heck-just-happened?

For applications which ignore the continuation flags, this would lead
to a different output.  We can fake it for /dev/kmsg (concatenate from
the kernel side and then output empty message for the later fragments)
but that'd be piling more hacks on top of already unnecessary hack
which is the cont buffer.

We can generate a log message indicating that the new mode is enabled
to make it easier to figure out why it changed.  Given that this is
not an entirely new behavior and the usage of extended console is
likely to stay fairly specific, transitioning this way is unlikely to
cause too much trouble especially given that most traditional tools
use the older interfaces w/o metadata which aren't affected by this
change.

What do you think?

Thanks.

-- 
tejun
