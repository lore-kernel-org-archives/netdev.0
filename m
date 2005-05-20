From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: patch tulip-natsemi-dp83840a-phy-fix.patch added to -mm tree
Date: Fri, 20 May 2005 14:58:58 -0400
Message-ID: <428E3372.403@pobox.com>
References: <200505101955.j4AJtX9x032464@shell0.pdx.osdl.net> <42881C58.40001@pobox.com> <20050516050843.GA20107@colo.lackof.org> <4288CE51.1050703@pobox.com> <20050516222612.GD9282@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: T-Bone@parisc-linux.org, varenet@parisc-linux.org,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Grant Grundler <grundler@parisc-linux.org>, akpm@osdl.org
In-Reply-To: <20050516222612.GD9282@colo.lackof.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Grant Grundler wrote:
> After three years of using/maintaining the (trivial) tulip patch
> in parisc-linux tree (and shipped with RH/SuSe ia64 releases),
> I don't recall anyone complaining that udelays in tulip phy reset
> caused them problems. Sorry, I'm unmotivated to revisit this.
> Convince someone else to make tulip to use workqueues and I'll
> resubmit a clean patch on top of that for the phy init sequences.


Long delays are unacceptable in new drivers, and we are working to 
remove them from older drivers.  Lack of complaints is irrelevant -- its 
a design requirement of all drivers.

Ingo and the real-time crowd are fighting against every delay, because 
every delay causes a spin, a blip in latency, an increase in CPU usage, 
and a complete stoppage of ALL work on a uniprocessor machine.

Your patch is not a special case.  We have been communicating this 
message on udelay/mdelay for -years-.  All your patch [as-is] does is 
cause more work for someone else.

This also presents a problem that Andrew points out on occasion:
what happens when a patch is useful, but the patch author isn't (for 
whatever reason) doing the legwork necessary to get it into the mainline 
kernel?  We certainly DON'T want to lose this patch, as the changes are 
useful.

	Jeff
