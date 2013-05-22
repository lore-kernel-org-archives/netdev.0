From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH v4 06/12] ARM: dove: add gigabit ethernet and mvmdio device
 tree nodes
Date: Wed, 22 May 2013 20:44:20 +0200
Message-ID: <519D1204.4090701@gmail.com>
References: <1369154510-4927-7-git-send-email-sebastian.hesselbarth@gmail.com> <20130521174849.GL26249@lunn.ch> <519C9333.20609@gmail.com> <519C9822.9040909@windriver.com> <519C9A66.3050807@gmail.com> <20130522131010.GB31290@titan.lakedaemon.net> <20130522165908.GB12320@obsidianresearch.com> <519D0143.1000203@gmail.com> <20130522173505.GH31290@titan.lakedaemon.net> <519D038C.9000605@gmail.com> <20130522174815.GI31290@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	"tiejun.chen" <tiejun.chen@windriver.com>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130522174815.GI31290@titan.lakedaemon.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2013 07:48 PM, Jason Cooper wrote:
> On Wed, May 22, 2013 at 07:42:36PM +0200, Sebastian Hesselbarth wrote:
>> Hmm, maybe a little bit too early. While restoring the MAC address now
>> works, another bug arises which I guess is related with phy setup
>> and aneg.
>>
>> Will investigate and update patch set accordingly.
>
> Cool, chances are, we should be able to take that patch in by itself for
> this merge window...

Which patch do you mean? The local-mac-address workaround will only be
available for DT mv643xx_eth because it uses the DT node to store the
MAC.

Anyway, I found the bit that caused the other issue. It is the
Clk125_Bypass_En bit in PORT_SERIAL_CONTROL1 register. What bothers me
about it is:
- Only Dove and Kirkwood have the bit, MV78x00 doesn't have it, Orion5x
   doesn't have the register at all. With ppc mv64x60 I can only guess,
   but think it is like in Orion5x.
- Reset value of that bit should be 0, but after gating clock on
   Kirkwood it is set to 1 causing wrong port clock to be selected.
   Also Thomas Petazzoni confirmed that it is set after reset so
   either FS is wrong about it or BootROM messes with it.
- Kirkwood and Dove FS tell me that port link must be down when you
   change the bit.

As I can't be sure about how mv643xx_eth will behave on other platforms
except Kirkwood and Dove when writing that register, I tend to force
that bit to zero in the driver but only for those two by #ifdefs.

Sebastian
