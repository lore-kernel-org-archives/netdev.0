From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: tg3 adapter losing link - PM related?
Date: Fri, 3 May 2013 08:13:15 -0700
Message-ID: <5183D40B.8090605@broadcom.com>
References: <20130503092846.GA5126@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Nikola Ciprich" <nikola.ciprich@linuxbox.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3832 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758210Ab3ECPNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 May 2013 11:13:24 -0400
In-Reply-To: <20130503092846.GA5126@pcnci.linuxbox.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nikola,
1. What device is present on this server? Can you give the tg3 messages 
in /var/log/messages? Can you also give the output of "ethtool -i <iface>"?

2. Is it possible for you to try the latest 3.9 upstream kernel?

3. Any reason why the link is at 100Mb? The switch does not support gig? 
What switch is it?

4. I don't think you can turn off EEE in the bios, but you can try 
turning autoneg off. Try "ethtool -s <iface> speed 100 duplex full 
autoneg off". It's not exactly the same thing since the device still has 
EEE enabled but not negotiated.

Nithin.


On 5/3/2013 2:28 AM, Nikola Ciprich wrote:
> Hello,
>
> I'd like to ask about trouble I've got with new HP server: tg3 adapter keeps losing
> link every few minutes:
>
> Aug  3 03:58:02 atlovav1a kernel: [616741.147598] tg3 0000:03:00.0: eth0: Link is down
> Aug  3 03:58:04 atlovav1a kernel: [616743.943456] tg3 0000:03:00.0: eth0: Link is up at 100 Mbps, full duplex
> Aug  3 03:58:04 atlovav1a kernel: [616743.943598] tg3 0000:03:00.0: eth0: Flow control is on for TX and on for RX
> Aug  3 03:58:04 atlovav1a kernel: [616743.943736] tg3 0000:03:00.0: eth0: EEE is enabled
> Aug  3 04:14:29 atlovav1a kernel: [617727.980487] tg3 0000:03:00.0: eth0: Link is down
> Aug  3 04:14:32 atlovav1a kernel: [617730.847245] tg3 0000:03:00.0: eth0: Link is up at 100 Mbps, full duplex
> Aug  3 04:14:32 atlovav1a kernel: [617730.847387] tg3 0000:03:00.0: eth0: Flow control is on for TX and on for RX
> Aug  3 04:14:32 atlovav1a kernel: [617730.847525] tg3 0000:03:00.0: eth0: EEE is enabled
> Aug  3 06:47:13 atlovav1a kernel: [626885.452974] tg3 0000:03:00.0: eth0: Link is down
> Aug  3 06:47:15 atlovav1a kernel: [626888.218702] tg3 0000:03:00.0: eth0: Link is up at 100 Mbps, full duplex
> Aug  3 06:47:15 atlovav1a kernel: [626888.218844] tg3 0000:03:00.0: eth0: Flow control is on for TX and on for RX
> Aug  3 06:47:15 atlovav1a kernel: [626888.218982] tg3 0000:03:00.0: eth0: EEE is enabled
> Aug  3 06:51:44 atlovav1a kernel: [627156.293386] tg3 0000:03:00.0: eth0: Link is down
> Aug  3 06:51:46 atlovav1a kernel: [627159.123347] tg3 0000:03:00.0: eth0: Link is up at 100 Mbps, full duplex
> Aug  3 06:51:46 atlovav1a kernel: [627159.123491] tg3 0000:03:00.0: eth0: Flow control is on for TX and on for RX
> Aug  3 06:51:46 atlovav1a kernel: [627159.123629] tg3 0000:03:00.0: eth0: EEE is enabled
> Aug  3 07:13:10 atlovav1a kernel: [628441.722197] tg3 0000:03:00.0: eth0: Link is down
> Aug  3 07:13:13 atlovav1a kernel: [628444.615548] tg3 0000:03:00.0: eth0: Link is up at 100 Mbps, full duplex
> Aug  3 07:13:13 atlovav1a kernel: [628444.615690] tg3 0000:03:00.0: eth0: Flow control is on for TX and on for RX
> Aug  3 07:13:13 atlovav1a kernel: [628444.615828] tg3 0000:03:00.0: eth0: EEE is enabled
>
> I can't exclude the possibility it's switch problem, but I don't have access to box now and the
> switch is not managed, so I'd like to try other ways first..
>
> Could this somehow be power management related? I don't see what else PM-related could I disable
> in the bios to disable this EEE stuff.. Didn't anyone met similar problem?
>
> the system is running Centos6 with x86_64 3.0.76 kernel
>
> thanks in advance for any reply
>
> BR
>
> nik
>
>
