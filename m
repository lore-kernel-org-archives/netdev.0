From: wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Subject: Re: [PATCH] ethernet: atheros: Add nss-gmac driver
Date: Mon, 19 Jan 2015 21:58:09 -0000
Message-ID: <3ad19b16fe5c58612479f70c052d0045.squirrel@www.codeaurora.org>
References: <1420754626-30121-1-git-send-email-wstephen@codeaurora.org>
    <5550127.3sXOcCISZN@wuerfel>
    <bca0eaf2183036ff6a913daea6e09ad9.squirrel@www.codeaurora.org>
    <2318041.V2OJAPu7gC@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, jcliburn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Arnd Bergmann" <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2318041.V2OJAPu7gC@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> On Thursday 15 January 2015 08:12:51 wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org wrote:
>>
>> The nss-gmac driver is for the internal GMAC IP in the Qualcomm IPQ806x
>> SoC. There are 2 ARM cores and 2 NSS cores inside the IPQ806x SoC. The
>> main purpose of these NSS cores is to offload the networking stack from
>> the ARM cores to achieve high performance at routing/ipsec..etc without
>> exhausting the ARM core CPU cycles. There is another nss-drv driver for
>> the NSS cores.
>
> I see.
>
>> The nss-gmac driver is designed to work standalone or with the nss-drv
>> driver so the switchable data plane overlay was implemented. When it
>> worked standalone, the data plane is running on the ARM core as a
>> standard
>> networking driver.
>
> How do you decide which way it gets used on a particular system?
>

By default the GMAC driver uses a native (Host ARM CPU) based data plane. 
If the configuration loads the offload nss-drv driver, the offload driver
registers an overlay with the GMAC.

>> The nss-drv driver can take over the data plane and
>> offload it to the NSS cores. The STMicro stmmac driver does not have
>> this
>> kind of overlay design so is not suitable for IPQ806x. This is why we
>> don't based on the stmmac driver
>
> Which kind of offload is implemented specifically? 'data plane' sounds
> fairly generic and could mean anything, and the code isn't readable enough
> in its current form for me to find out.

The Network Subsystem (NSS core) provides a GMAC pass-through until it is
given a rule to offload work.  Once a rule is given, it is capable of
performing: bridging, IPv4 NAT/FWD, IPv6 NAT/FWD, IPSec, LAG, and other
protocols.
>
> 	Arnd
>

Hope this clarify your question!

Thanks,
Stephen


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
