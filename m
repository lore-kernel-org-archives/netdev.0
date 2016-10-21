From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] kexec: Export kexec_in_progress to modules
Date: Fri, 21 Oct 2016 00:26:55 -0500
Message-ID: <871szagtls.fsf@xmission.com>
References: <1477012516-20470-1-git-send-email-f.fainelli@gmail.com>
        <20161020.215410.650162338407203719.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        kexec@lists.infradead.org, linux-kernel@vger.kernel.org,
        sfr@canb.auug.org.au
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161020.215410.650162338407203719.davem@davemloft.net> (David
        Miller's message of "Thu, 20 Oct 2016 21:54:10 -0400 (EDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Thu, 20 Oct 2016 18:15:16 -0700
>
>> The bcm_sf2 driver uses kexec_in_progress to know whether it can power
>> down an integrated PHY during shutdown, and can be built as a module.
>> Other modules may be using this in the future, so export it.
>> 
>> Fixes: 2399d6143f85 ("net: dsa: bcm_sf2: Prevent GPHY shutdown for kexec'd kernels")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>> Eric, David, Stephen,
>> 
>> The offending commit is in David's net.git tree, so it would probably make
>> sense to route the fix through the same tree.
>
> Ok, I'll apply this, thanks Florian.

Florian

I am completely confused why any driver would want to do this.

A reboot is semantically identical to a kexec restart.  Always has been.
That is pwoering down your hardware during reboot is not safe.

The only thing that might save you is the hardware reset line being
toggled at which point your hardware is powered up again anyway.

So as far as I can tell you are advocating for a change to support a
driver doing something that is completely pointless.  So no let's not
export this symbol.  Please fix the driver to do something less
pointless instead.

Eric
