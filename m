From: Andi Kleen <ak@suse.de>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond interfaces
Date: Tue, 13 Jan 2004 13:39:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113123922.GC31630@wotan.suse.de>
References: <E6F7D288B394A64585E67497E5126BA601F991D1@hasmsx403.iil.intel.com> <200401111628.07930.amir.noam@intel.com> <4001A667.2020904@pobox.com> <4001C158.6040103@candelatech.com> <4001C72E.8030108@pobox.com> <20040112133816.57993f44.ak@suse.de> <1073915461.1118.342.camel@jzny.localdomain> <20040112160446.691e187e.ak@suse.de> <1073996930.1039.247.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, jgarzik@pobox.com, greearb@candelatech.com,
        amir.noam@intel.com, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1073996930.1039.247.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 13, 2004 at 07:28:50AM -0500, jamal wrote:
> The behavior of some 32 bit archs alignof()e.g ppc is similar in
> aligning to its biggest member. 
> We have some major problems with include/linux/pkt_sched.h::tc_stats for
> example; i just have to keep hacking tc on ppc everytime so it doesnt
> stop processing and bitch about truncated stats; [this happens when
> doing a sizeof() of on-the-wire data passed from the kernel being
> compared against sizeof(tc_stats)]. I recall there are a few other
> similar structures. It didnt seem like there was a clean solution when i
> last looked at this. It seems we may need surgery on a few places like
> this and may require a few #ifdefs. Any thoughts on this particular one?

I don't think it can be fixed with #ifdefs. For existing structures
we cannot change the layout because they are already enshrined in the ABI.
You have to translate them in the emulation layer somehow or just give up.
And for new ones just add all necessary padding explicitely or best avoid
__u64 (which causes most problems)

In fact we should have some watchdog enforcing these rules for all new
kernel submissions </dreaming>. In fact DaveM did that for some time,
but he unfortunately only enforced the rules needed for sparc64 which
are a subset of those needed by other ports.

-Andi
