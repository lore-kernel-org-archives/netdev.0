From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Sat, 05 Feb 2005 13:26:25 +0000
Message-ID: <4204C981.6050102@phekda.gotadsl.co.uk>
References: <41A0F0D5.9050702@phekda.gotadsl.co.uk> <20041121205814.GA22460@electric-eye.fr.zoreil.com> <41A24F35.5080106@phekda.gotadsl.co.uk> <20041122213008.GA9618@electric-eye.fr.zoreil.com> <41D2844E.5070204@phekda.gotadsl.co.uk> <20041229235203.GA5465@electric-eye.fr.zoreil.com> <41F250D1.8000207@phekda.gotadsl.co.uk> <41F26FD1.2060407@phekda.gotadsl.co.uk> <20050122230156.GC24461@electric-eye.fr.zoreil.com> <41F3F632.3060800@phekda.gotadsl.co.uk> <20050125214725.GA6093@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Me <rich@phekda.gotadsl.co.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050125214725.GA6093@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Francois Romieu wrote:
> Hi,
> 
>   could you give the patch below some testing ?
> 
> Any post-LLTX-revert 2.6.11-rc2-bk should do.
> 
> Merge of Realtek's code
> - code dedicated to a new phy (spotted by Richard Dawe);
> - C+ register fiddling seems required for both RTL_GIGA_MAC_VER_{D/E};
> - apart from being reserved, register at address 0xe2 is named 'IntrMitigate';
> - bump version number.
>   A bunch of people do not use the vanilla kernel module simply because
>   Realtek's driver has a higher revision number. This is not an issue per
>   se but their driver is buggy due to some partial merge of in-kernel code.
[snip]

Applied to 2.6.11-rc3. It seems to work fine. I've passed ~20GB of data 
at 100Mbps full-duplex with no errors (compared MD5 sums on files). My 
data rate test (sftp of Linux kernel source tarball) gave about the same 
data rate as 1.6LK + PHY patch - ~7.1MB/sec.

It works fine setting the speed & duplex using "ethtool -s eth0 autoneg 
off speed <speed> duplex <duplex>".

I haven't tested the VLAN or jumbo(ish) frames. Let me know if you'd 
like me to test those too. Although I'm not sure if I can test jumbo 
frames with the equipment I have.

One more thing:

With 1.6LK + my PHY patch, I see the message "eth0: PHY reset until link 
up" every 5 seconds or so, when there is no Ethernet cable plugged in. 
This is annoying. I think it should only log it once.

I'll repeat my cable removal/insertion tests with 2.2LK later and let 
you know what I find.

Bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
