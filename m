From: John Partridge <johnip@sgi.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Tue, 14 Oct 2003 11:49:14 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F8C290A.3010508@sgi.com>
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


The key point for me is, as David said yesterday, SGI users will only
have to recompile the tg3 driver with the CONFIG defined to get the desired
behavior, not hte whole kernel. They just use the recompiled driver with
whatever kernel they are using. Users who use SGI propack will already
have the (static) driver with the CONFIG defined by SGI, SuSE users
who use a tg3.o use it as a module anyway, so it's not a big deal
just to recompile tg3. The only problem I can see is if users use RedHat
Advanced Server, I believe the tg3 driver is static in the kernel so they
won't be able to just recompile the tg3 driver.

I do propose that we make the CONFIG a little more descriptive something like

  CONFIG_5701PCIX_UNALIGNED_EXPENSIVE

just to make it easier for users to see what it does.

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
> 

-- 
John Partridge

Silicon Graphics Inc
Tel:  651-683-3428
Vnet: 233-3428
E-Mail: johnip@sgi.com
