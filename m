From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: Problems with tg3 on BCM5720
Date: Wed, 26 Sep 2012 14:13:14 -0700
Message-ID: <50636FEA.7080509@broadcom.com>
References: <CAKmKYaCBG5hURNomffgp9gRhS7g2BYsNG-LTmBrKsX-iyVzVxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Dirkjan Ochtman" <dirkjan@ochtman.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1379 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752333Ab2IZVNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 17:13:23 -0400
In-Reply-To: <CAKmKYaCBG5hURNomffgp9gRhS7g2BYsNG-LTmBrKsX-iyVzVxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dirkjan,
A few questions -
1. Can you tell me the last patch that is included in the tg3 driver in 3.4.9 on your distro?
2. Can you give more info about the working setup?
3. Was there any system reset or driver reload between the working and not working setups? Or was it 
just a cable switch?

4. Please give the output of
ethtool eth0
ethtool -i eth0
ethtool -k eth0

5. Can you run ethtool --test in the working setup?

6. I noticed in the syslog, the link is coming up at 100 Mbps. Is this expected?
7. Does it fail immediately on connect to the data center switch? Or is it after some traffic goes 
through?

Thanks,
Nithin.


On 09/26/2012 06:48 AM, Dirkjan Ochtman wrote:
> Hi,
>
> I hope this is the right list for this; please let me know if there is
> some more appropriate venue for this kind of problem.
>
> We have bought a Dell PowerEdge server recently with Broadcom ethernet
> controllers:
>
> 01:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5720
> Gigabit Ethernet PCIe
> 01:00.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5720
> Gigabit Ethernet PCIe
> 02:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5720
> Gigabit Ethernet PCIe
> 02:00.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5720
> Gigabit Ethernet PCIe
>
> Using the tg3 driver as provided by the 3.4.9 kernel (it's a distro
> kernel, but I verified that there are no relevant patches on top of
> the vanilla 3.4.9), networking works fine on a small VLAN. However,
> we've run into trouble connecting one of the interfaces to switch run
> by our data center vendor (the switch side works fine when connecting
> with a laptop). The driver keeps erroring out with "transmit timed
> out, resetting" (full syslog output is at [1]). This also keeps
> happening when I use the latest tg3.{c,h} from torvalds/linux-2.6
> (though I've had to revert a few things to make it compile inside the
> 3.4.9 kernel).
>
> I've also run some tests with ethtool:
>
> djc@jansky ~ $ sudo ethtool --test eth0
> The test result is FAIL
> The test extra info:
> nvram test        (online)       0
> link test         (online)       1
> register test     (offline)      0
> memory test       (offline)      0
> mac loopback test (offline)      7
> phy loopback test (offline)      7
> ext loopback test (offline)      0
> interrupt test    (offline)      1
>
> While I'd be happy to do more digging, at this point I'm out of ideas
> on how to go about that.
>
> Again, sorry if this is off-topic for this list, any help would be appreciated.
>
> Cheers,
>
> Dirkjan
>
> [1] http://dirkjan.ochtman.nl/files/tg3-fail.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
