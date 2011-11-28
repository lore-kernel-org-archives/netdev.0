From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Mon, 28 Nov 2011 10:17:28 +0100
Message-ID: <4ED351A8.8000102@grandegger.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com> <1322214204-1121-3-git-send-email-wg@grandegger.com> <4ED0FEC5.3070108@hartkopp.net> <4ED34CAD.7040000@essax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, socketcan-users@lists.berlios.de,
	IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>
To: info@essax.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4ED34CAD.7040000@essax.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/28/2011 09:56 AM, Wolfgang Zarre wrote:
> Hello Oliver,
> 
>> Hello Wolfgang,
>>
>> many thanks for posting this driver. Indeed this is the last from the
>> missing
>> drivers in the SVN ...
> 
> @Wolfgang
> 
> The same her, thanks a lot.
> 
>>
>> I added Wolfgang Zarre to the list of recipients who tested your CC770
>> driver
>> recently:
>>
>> http://old.nabble.com/Compile-Fails-On-2.6.39-2-td32259346.html
>>
>> Maybe he can check this latest version and can send a "Tested-by:"
>>
>> @Wolfgang Zarre: The entire patch set from Wolfgang Grandegger is here:
>>
>> http://patchwork.ozlabs.org/patch/127653/
>> http://patchwork.ozlabs.org/patch/127651/
>> http://patchwork.ozlabs.org/patch/127654/
>> http://patchwork.ozlabs.org/patch/127652/
> 
> In fact a month ago we discovered a problem with the previous isa driver
> but were not
> able to reproduce it.
> 
> Last Friday during a test run we got the same problem and with some
> further tests I
> was able to reproduce and started with some investigation.
> 
> So the patches came in quite handy and even not to waste time I was
> applying the
> patches to an updated svn tree but had to do some manual corrections to
> get it
> compiled.
> 
> So far the driver is functioning quite good and I was hoping that our
> problem would
> be solved as well.

Well, I do not remember any fix... apart from

> But unfortunately that is not the case and it would be great if somebody
> would have
> an idea or similar experience and maybe a solution.
> 
> In use:
> ISA card: B&R with CC770 (40007) Series Bosch CAN Controller - LQFP-44
> Kernel: 2.6.39.4
> Module: modprobe cc770_isa irq=0xa port=0x384 indirect=1
> Commands: ip link set can0 up type can bitrate 500000;ip link set can0
> txqueuelen 2000

... using a reasonable default for bcr of 0x40. But you may need to
provide better values for cir, bcr and cor.

> dmesg:
> [190911.144337] CAN device driver interface
> [190911.153316] cc770 CAN netdevice driver
> [190911.159708] cc770_isa: platform device 0: port=0x384, mem=0x0, irq=10
> [190911.159740] cc770_isa cc770_isa.0: probing idx=0: port=0x384,
> mem=0x0, irq=10
> [190911.159799] cc770_isa cc770_isa.0: (unregistered net_device): i82527
> mode with additional functions
> [190911.161338] cc770_isa cc770_isa.0: cc770_isa device registered
> (reg_base=0x00000384, irq=10)
> [190911.161384] Legacy cc770_isa driver for max. 8 devices registered
> [190912.173762] cc770_isa cc770_isa.0: can0: setting BTR0=0x00 BTR1=0x1c
> [190912.173835] cc770_isa cc770_isa.0: can0: Message object 15 for RX
> data, RTR, SFF and EFF
> [190912.173852] cc770_isa cc770_isa.0: can0: Message object 11 for TX
> data, RTR, SFF and EFF
> 
> 
> Description of problem:
> After a while sending quite some telegrams the driver of a sudden stops
> transmitting
> and the queue is running full but still capable to receive telegrams.
> This issue is not depending on the amount of transmitted telegrams and
> also no logfile
> entries.

What do you get with "candump -t d any,0:0,#FFFFFFFF"? What does "ip -d
-s link show" show?

Wolfgang.

