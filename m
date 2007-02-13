From: Philip Craig <philipc@snapgear.com>
Subject: Re: [PATCH 4/5] r8169: more alignment for the 0x8168
Date: Wed, 14 Feb 2007 09:56:18 +1000
Message-ID: <45D25022.1010607@snapgear.com>
References: <20061203235257.GA3625@electric-eye.fr.zoreil.com> <20061204000327.GE3625@electric-eye.fr.zoreil.com> <45D13578.8040405@snapgear.com> <20070213081439.GA21261@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	isely@pobox.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:36876 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751461AbXBMX5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 18:57:08 -0500
In-Reply-To: <20070213081439.GA21261@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Philip Craig <philipc@snapgear.com> :
> [...]
>> This patch caused a drop in throughput from 178 Mbits/sec to 135 Mbits/sec
>> on an Intel XScale IXP465.
> 
> Which distribution of packet sizes ?

Just using iperf with the default options, MTU 1500,
forwarding between 2 PCs with the board in the middle.

>> It seems like there is some confusion about what the align parameter
>> here means. It was originally an offset from an aligned address so that
>> the IP header aligned, and this patch changes it to the alignment of the
>> ethernet header. But align is still set to NET_IP_ALIGN for some chips.
> 
> Yes, I should have distinguished both in the first place.
> 
> Can you describe which chipset from realtek the board is using (lspci -vxx) ?

# lspci -vxx
00:0c.0 Ethernet controller: Realtek Semiconductor Co., Ltd.: Unknown device 8169 (rev 10)
        Subsystem: Realtek Semiconductor Co., Ltd.: Unknown device 8169
        Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 26
        I/O ports at 1000 [size=256]
        Memory at 48061000 (32-bit, non-prefetchable) [size=256]
        Expansion ROM at 48000000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
00: ec 10 69 81 57 01 b0 02 10 00 00 02 08 00 00 00
10: 01 10 00 00 00 10 06 48 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ec 10 69 81
30: 00 00 00 00 dc 00 00 00 00 00 00 00 1a 01 20 40

00:0d.0 Ethernet controller: Realtek Semiconductor Co., Ltd.: Unknown device 8169 (rev 10)
        Subsystem: Realtek Semiconductor Co., Ltd.: Unknown device 8169
        Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 26
        I/O ports at 1400 [size=256]
        Memory at 48061100 (32-bit, non-prefetchable) [size=256]
        Expansion ROM at 48020000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
00: ec 10 69 81 57 01 b0 02 10 00 00 02 08 00 00 00
10: 01 14 00 00 00 11 06 48 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ec 10 69 81
30: 00 00 00 00 dc 00 00 00 00 00 00 00 1a 01 20 40

