From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Tue, 08 Feb 2005 23:00:59 +0000
Message-ID: <420944AB.5090501@phekda.gotadsl.co.uk>
References: <41A24F35.5080106@phekda.gotadsl.co.uk> <20041122213008.GA9618@electric-eye.fr.zoreil.com> <41D2844E.5070204@phekda.gotadsl.co.uk> <20041229235203.GA5465@electric-eye.fr.zoreil.com> <41F250D1.8000207@phekda.gotadsl.co.uk> <41F26FD1.2060407@phekda.gotadsl.co.uk> <20050122230156.GC24461@electric-eye.fr.zoreil.com> <41F3F632.3060800@phekda.gotadsl.co.uk> <20050125214725.GA6093@electric-eye.fr.zoreil.com> <4204C981.6050102@phekda.gotadsl.co.uk> <20050205204135.GA13986@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Me <rich@phekda.gotadsl.co.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050205204135.GA13986@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Francois Romieu wrote:
[snip]
> If you can do an extra test, I'd like to know if you can safely bring
> the r8169 interface down on your computer once the patch below if applied:
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.11-rc3/r8169/patches/r8169-380.patch
> 
> (it should apply correctly on top of you current setup)

I can, with and without that patch.

But I encounter problems bringing the interface back up and down again. 
If I do the following after a reboot:

   /etc/init.d/network stop
   /etc/init.d/network start
   /etc/init.d/network stop

I find that the "ip link set dev eth0 down" command hangs, consuming 
most of the CPU time (~99%). Note that I issued the "network" commands 
with about a second's delay between each command.

This is with a static IP address. If the IP address is assigned via 
DHCP, then the DHCP client hangs in the "network start" command.

I'm running Fedora Core 3 + all the latest security updates.

>>One more thing:
>>
>>With 1.6LK + my PHY patch, I see the message "eth0: PHY reset until link 
>>up" every 5 seconds or so, when there is no Ethernet cable plugged in. 
>>This is annoying. I think it should only log it once.
> 
> 
> Hmmm... One could argue that 1) syslog will cope and 2) the printk level
> of the console can be lowered. Some event kamasutra can probably be done
> from userspace too so I am a bit reluctant to special case this code
> (read as: I'd welcome more requests/complaints).
> 
> Is it enough for you if I salt the code with a few netif_msg_xxx() here
> and there to control the messages ?

That sounds good.

I'm happy to submit a patch to do this, if you'd like. Note that I'm new 
to kernel programming, so it might take me a while.

Bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
