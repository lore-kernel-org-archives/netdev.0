From: Andi Kleen <ak@suse.de>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond
 interfaces
Date: Mon, 12 Jan 2004 16:04:46 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040112160446.691e187e.ak@suse.de>
References: <E6F7D288B394A64585E67497E5126BA601F991D1@hasmsx403.iil.intel.com>
	<200401111628.07930.amir.noam@intel.com>
	<4001A667.2020904@pobox.com>
	<4001C158.6040103@candelatech.com>
	<4001C72E.8030108@pobox.com>
	<20040112133816.57993f44.ak@suse.de>
	<1073915461.1118.342.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, greearb@candelatech.com, amir.noam@intel.com,
        bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1073915461.1118.342.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 12 Jan 2004 08:51:02 -0500
jamal <hadi@cyberus.ca> wrote:

> Andi,
> Can you point to specifics that break 64 bit emulation so we can avoid
> them?
> I have to admit the pf_key interaction is relatively unorthrodox but
> looked fine.

Ok, here are the full rules: 

Standards:

long/void * are disallowed
use [su]{16,32,64} instead

Non obvious problems specific to IA64 and x86-64 (they don't happen on sparc64/ppc64,
that is why they were often not catched earlier):

When you use [su]64: 

make sure the data element is explicitely padded to be on a 8 byte boundary
in the structure. The reason is that alignof(u64) on i386 is 4 but 8 on ia64/x86-64
and the structure layout could change.

also when you use 64bit types make sure the complete structure is padded to 8 bytes.
The x86-64 ABI pads any data structure to the alignof() of its biggest member
to get good alignment for arrays. This is what broke PF_KEY - it is missing this
padding and the structure layout ends up differently with nested structures.

> What are the things you will perform surgery on?

I'm not sure I will because it is too ugly. Or at least I haven't found a nice elegant
way for it yet. Currently you just cannot use ipsec from 32bit executables, you have to use 
64bit. 

-Andi
 
