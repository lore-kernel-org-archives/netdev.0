From: John Partridge <johnip@sgi.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Mon, 13 Oct 2003 14:53:54 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F8B02D2.4020007@sgi.com>
References: <3F844578.40306@sgi.com>	<20031008101046.376abc3b.davem@redhat.com>	<3F8455BE.8080300@sgi.com>	<20031008183742.GA24822@wotan.suse.de>	<20031008122223.1ba5ac79.davem@redhat.com>	<20031008202248.GA15611@oldwotan.suse.de>	<3F8702FF.70500@sgi.com>	<20031010192036.GA31727@wotan.suse.de>	<3F8802E6.5030601@sgi.com>	<20031011131921.GC21763@wotan.suse.de> <20031011105054.0e16a607.davem@redhat.com>
Reply-To: johnip@sgi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, modica@sgi.com, netdev@oss.sgi.com,
        jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031011105054.0e16a607.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Could we create a module argument like "do_5701_align" and just give it a -1
default which does NOT do the copy but if we give the arg 1, 0, whatever it
DOES to the copy to align the buffs ?

Then inside the driver we define a macro to handle that ?

That way all you need is to include "tg3 do_5701_align=1" in modules.conf

That way all the default comiles work and no CONFIG option for people
who compile all defaults and don't want to re compile the kernel for
this issue.

Is that acceptable ?

John

David S. Miller wrote:
> On Sat, 11 Oct 2003 15:19:21 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> 
>>Then just don't set the argument to zero in modules.conf on the 5704cards. 
>>That could be even handled somewhere in user space.  Switching over sounds 
>>best of course, because the performance with the copying won't be great
> 
> 
> There is no "argument" we don't have a variable in the tg3 driver
> that determines the "copybreak", it's a hard-coded macro define.
> 
> For them it's really easy to know when the 5701 hw bug case is present,
> so they can do something like:
> 
> 	if (len > RX_COPY_THRESHOLD
> #ifdef CONFIG_UNALIGNED_EXPENSIVE
> 	    || tp->rx_offset == 2
> #endif
> 	    ) {
>         ...
> 
> And then only their platform and only when the buggy chips are present,
> will get the desired change in behavior.

-- 
John Partridge

Silicon Graphics Inc
Tel:  651-683-3428
Vnet: 233-3428
E-Mail: johnip@sgi.com
