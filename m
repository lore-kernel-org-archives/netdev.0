From: jamal <hadi@cyberus.ca>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond
	interfaces
Date: 13 Jan 2004 07:28:50 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1073996930.1039.247.camel@jzny.localdomain>
References: <E6F7D288B394A64585E67497E5126BA601F991D1@hasmsx403.iil.intel.com>
	 <200401111628.07930.amir.noam@intel.com> <4001A667.2020904@pobox.com>
	 <4001C158.6040103@candelatech.com> <4001C72E.8030108@pobox.com>
	 <20040112133816.57993f44.ak@suse.de>
	 <1073915461.1118.342.camel@jzny.localdomain>
	 <20040112160446.691e187e.ak@suse.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, greearb@candelatech.com, amir.noam@intel.com,
        bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040112160446.691e187e.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-01-12 at 10:04, Andi Kleen wrote:
[..]
> When you use [su]64: 
> 
> make sure the data element is explicitely padded to be on a 8 byte boundary
> in the structure. The reason is that alignof(u64) on i386 is 4 but 8 on ia64/x86-64
> and the structure layout could change.
> 
>
> also when you use 64bit types make sure the complete structure is padded to 8 bytes.
> The x86-64 ABI pads any data structure to the alignof() of its biggest member
> to get good alignment for arrays. This is what broke PF_KEY - it is missing this
> padding and the structure layout ends up differently with nested structures.
> 

The behavior of some 32 bit archs alignof()e.g ppc is similar in
aligning to its biggest member. 
We have some major problems with include/linux/pkt_sched.h::tc_stats for
example; i just have to keep hacking tc on ppc everytime so it doesnt
stop processing and bitch about truncated stats; [this happens when
doing a sizeof() of on-the-wire data passed from the kernel being
compared against sizeof(tc_stats)]. I recall there are a few other
similar structures. It didnt seem like there was a clean solution when i
last looked at this. It seems we may need surgery on a few places like
this and may require a few #ifdefs. Any thoughts on this particular one?

cheers,
jamal
