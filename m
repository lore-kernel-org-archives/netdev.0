From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Sat, 5 Feb 2005 21:41:35 +0100
Message-ID: <20050205204135.GA13986@electric-eye.fr.zoreil.com>
References: <41A24F35.5080106@phekda.gotadsl.co.uk> <20041122213008.GA9618@electric-eye.fr.zoreil.com> <41D2844E.5070204@phekda.gotadsl.co.uk> <20041229235203.GA5465@electric-eye.fr.zoreil.com> <41F250D1.8000207@phekda.gotadsl.co.uk> <41F26FD1.2060407@phekda.gotadsl.co.uk> <20050122230156.GC24461@electric-eye.fr.zoreil.com> <41F3F632.3060800@phekda.gotadsl.co.uk> <20050125214725.GA6093@electric-eye.fr.zoreil.com> <4204C981.6050102@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
Content-Disposition: inline
In-Reply-To: <4204C981.6050102@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Dawe <rich@phekda.gotadsl.co.uk> :
[...]
> Applied to 2.6.11-rc3. It seems to work fine. I've passed ~20GB of data 
> at 100Mbps full-duplex with no errors (compared MD5 sums on files). My 

So it can be considered that the link detection issue is gone.
Ok, I'll ask Jeff to submit it for mainline.

> data rate test (sftp of Linux kernel source tarball) gave about the same 
> data rate as 1.6LK + PHY patch - ~7.1MB/sec.

If this test is (sys) CPU bound, then you should see a difference when
SG and TX csum is enabled.

> It works fine setting the speed & duplex using "ethtool -s eth0 autoneg 
> off speed <speed> duplex <duplex>".

Nice.
Does it stand an 'ethtool -s eth0 autoneg on' after this point ?

> I haven't tested the VLAN or jumbo(ish) frames. Let me know if you'd 
> like me to test those too. Although I'm not sure if I can test jumbo 
> frames with the equipment I have.

Hardly.

If you can do an extra test, I'd like to know if you can safely bring
the r8169 interface down on your computer once the patch below if applied:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.11-rc3/r8169/patches/r8169-380.patch

(it should apply correctly on top of you current setup)

> One more thing:
> 
> With 1.6LK + my PHY patch, I see the message "eth0: PHY reset until link 
> up" every 5 seconds or so, when there is no Ethernet cable plugged in. 
> This is annoying. I think it should only log it once.

Hmmm... One could argue that 1) syslog will cope and 2) the printk level
of the console can be lowered. Some event kamasutra can probably be done
from userspace too so I am a bit reluctant to special case this code
(read as: I'd welcome more requests/complaints).

Is it enough for you if I salt the code with a few netif_msg_xxx() here
and there to control the messages ?

--
Ueimor
