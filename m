From: Luca Bortot <l.bortot@inet.it>
Subject: Re: jumbo on 8169
Date: Mon, 27 Dec 2004 15:00:02 +0100
Message-ID: <41D01562.4090606@inet.it>
References: <41CFF27A.2070008@inet.it> <20041227123136.GA25187@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
In-Reply-To: <20041227123136.GA25187@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Luca Bortot <l.bortot@inet.it> :
>>To put it short, could you please give me a link or a hint or whatever 
>>to let me set jumbo frames on r8169 (I'm currently running kernel 
>>6.9.10/i386)?
> 
> 
> You can use any recent patch issued by Andrew Morton (-mm) or apply
> http://www.fr.zoreil.com/people/francois/misc/20041218-2.6.10-rc3-r8169.c-test.patch
> 
> I have not regenerated the whole patch against 2.6.10 yet. So if you want
> to apply the aforementionned patch on top of 2.6.10, you will have to revert
> (cd linux-2.6.10; patch -R -p1 -d. < ...) the attached patch first.
> 
> Please note that you will be limited to ~7000 bytes frames at most (but it
> is enough to make a noticeable difference).
> 
> Success/failure report + description of the hardware (lspci -vx/dmesg) will
> be welcome.

It did it as it should:

applied the patch, recompiled & reboot, could now run
ifconfig eth2 mtu 7000

hardware in short:
intel p3 800mhz
384mb ram
m/b QDI Advance 9
nic Hamlet HNNG32TX (realtek 8169 based)

running fedora core 3 / kernel 2.6.10 / NAPI enabled


I'm testing it together with a windows box (which is directly connected 
via a cross cable):
athlon XP 2600
1gb ram
m/b asus a7n8x
same nic
windows XP

based on a simple tcp test I made (writes zeroes to a socket in 32Kb 
blocks and prints the write speed), these are the results (win box cpu 
not reported - always under 10% load):

BEFORE PATCH (mtu 1500)
speed ~38 MB/s
cpu idle 10%
cpu system 90%

AFTER PATCH (mtu 7000)
speed ~45MB/s
cpu idle 40%
cpu system 60%


as requested, lspci /vx

00:0b.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 
Gigabit Ethernet (rev 10)
         Subsystem: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit 
Ethernet
         Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 5
         I/O ports at dc00 [size=256]
         Memory at e6603000 (32-bit, non-prefetchable) [size=256]
         Expansion ROM at e3000000 [disabled] [size=128K]
         Capabilities: [dc] Power Management version 2
00: ec 10 69 81 17 00 b0 02 10 00 00 02 08 40 00 00
10: 01 dc 00 00 00 30 60 e6 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ec 10 69 81
30: 00 00 00 e3 dc 00 00 00 00 00 00 00 05 01 20 40


Thanks for helping
Luca Bortot
