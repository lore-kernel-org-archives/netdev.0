From: Chris Packham <Chris.Packham@alliedtelesis.co.nz>
Subject: Re: [PATCHv3 4/5] arm: mvebu: Add device tree for 98DX3236 SoCs
Date: Thu, 26 Jan 2017 20:07:47 +0000
Message-ID: <3493169361fe445ba971951b40360301@svr-chch-ex1.atlnz.lc>
References: <20170105033641.6212-1-chris.packham@alliedtelesis.co.nz>
 <20170106041517.9589-1-chris.packham@alliedtelesis.co.nz>
 <20170106041517.9589-5-chris.packham@alliedtelesis.co.nz>
 <87inp1zwlg.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Lunn <andrew@lunn.ch>,
 Jason Cooper <jason@lakedaemon.net>,
 "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Russell King <linux@armlinux.org.uk>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Rob Herring <robh+dt@kernel.org>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 27/01/17 04:10, Gregory CLEMENT wrote:
> Hi Chris,
>
>  On ven., janv. 06 2017, Chris Packham <chris.packham@alliedtelesis.co.nz> wrote:
>
>> The Marvell 98DX3236, 98DX3336, 98DX4521 and variants are switch ASICs
>> with integrated CPUs. They are similar to the Armada XP SoCs but have
>> different I/O interfaces.
>
> Before sending a new version I have a few remarks:
>
>

[snip]

I'll update the dtsi files to use the node labels and correct the 
commends as requested

>
> Why the following node is not part of the dtsi?
>
> Gregory
>
>> +			resume@20980 {
>> +				compatible = "marvell,98dx3336-resume-ctrl";
>> +				reg = <0x20980 0x10>;
>> +			};
>> +		};
>> +	};

The 98DX9236 has a single ARMv7 core. As such this resume control isn't 
present on it. The 98DX3336 and 98DX4521 have dual ARMv7 cores and this 
is used to boot the second core (SMP support is a little different 
compared to Armada-XP).

In other words {98DX3336, 98DX4521} = 98DX9236 + an additional core. At 
the switch packet processor level there are more differences but as far 
as the kernel is concerned the only real difference is the number of cores.
