From: Boris BREZILLON <boris.brezillon@free-electrons.com>
Subject: Re: [PATCH] netdev: add support for interface name retrieval from
 DT aliases
Date: Fri, 09 May 2014 10:26:46 +0200
Message-ID: <536C9146.2060007@free-electrons.com>
References: <1399390594-1409-1-git-send-email-boris.brezillon@free-electrons.com> <20140508.224252.1337086843732451389.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140508.224252.1337086843732451389.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On 09/05/2014 04:42, David Miller wrote:
> From: Boris BREZILLON <boris.brezillon@free-electrons.com>
> Date: Tue,  6 May 2014 17:36:34 +0200
>
>> There is currently no proper way to bind a net interface to a specific
>> name. The interface name is chosen based on the interface type (eth,
>> wlan, ...) and the interfaces already registered (the core codes takes
>> the first unused interface id of the given type).
>>
>> Add support for DT retrieval of the interface id based on DT aliases.
>> The alias name must match the interface type (e.g. ethX if you're defining
>> an ethernet dev alias).
>>
>> Signed-off-by: Boris BREZILLON <boris.brezillon@free-electrons.com>
> This really isn't kosher at all.

Just for my personal knowledge, what is wrong with this code ?
Is it because I'm using "of_" functions in the core code, and you want
to keep it DT agnostic ?
Or is it something else ?

>
> And there absolutely is a proper way to bind a net interface to
> a specific name, udev has provided this facility for years.

Thanks for pointing this out.

But, what if the system does not use udev (this is often the case on
embedded systems where udev is replaced by mdev) ?
Moreover, on embedded systems, most users rely on the default interface
name provided by the kernel.

IIRC (tell me if I'm wrong), before moving to DT we could control the
probe order of net interfaces derived from platform devices by modifying
the platform dev registration order (okay, this is only true if the
platform devices are controlled by the same driver, which is often the
case when a SoC provides several net interfaces).
With DT we can't know for sure the exact probe order because it depends
on the net interface node position in the DT, and this node position
might change over the time (or at least it used to change, now that
we're enforced to declare DT nodes in strict memory @ order it should
not change that much).

Another issue: what if I want to rename eth0 into eth1 and eth1 into eth0 ?
I guess I'll have to execute this sequence: eth1 -> eth2, eth0 -> eth1,
eth2 -> eth0, otherwise the SIOCSIFNAME ioctl will return an error.

Best Regards,

Boris

-- 
Boris Brezillon, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
