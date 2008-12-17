From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 12242] New: ADMtek ADM8515 "Pegasus II" does
 not properly handle incoming 802.1q frames near MTU
Date: Wed, 17 Dec 2008 12:03:01 -0800
Message-ID: <20081217120301.a6eba80f.akpm@linux-foundation.org>
References: <bug-12242-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, mh+kernel-bugzilla-ciUMMiFYEj8OIzVOb1FTxg@public.gmane.org,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>,
	petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <bug-12242-10286-V0hAGp6uBxO456/isadD/XN4h3HLQggn@public.gmane.org/>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 17 Dec 2008 09:46:09 -0800 (PST)
bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12242
> 
>            Summary: ADMtek ADM8515 "Pegasus II" does not properly handle
>                     incoming 802.1q frames near MTU

It is my understanding that numerous drivers don't handle the larger
frames - each one needs to be specially tweaked to handle them.  Making
this a feature request.  I think.

>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.27.9
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
>         ReportedBy: mh+kernel-bugzilla-ciUMMiFYEj8OIzVOb1FTxg@public.gmane.org
> 
> 
> Latest working kernel version: none, it's a new device which I didn't try
> against older kernels
> Earliest failing kernel version: unknown, bug appears with 2.6.27.9
> Distribution: Debian unstable
> Hardware Environment: hp compaq nc 8000, Centrino (1st generation?) 
> connected via USB
> Software Environment: vconfig, ip, ping
> Problem Description: 
> 
> 802.1q tagged ethernet frames are four bytes longer than a normal ethernet
> frame. The four bytes are added to the layer 2 ethernet header. Hence, the MTU
> the OS sees is identical to untagged frames, but the driver needs to be able to
> handle frames that are four bytes larger.
> 
> The pegasus driver does not handle this properly and eats frames that are
> larger than the largest expected untagged frame.
> 
> Test setup:
> 
> -------------------
> |     Box 1       |
> -------------------
>         | ADMtek ADM8515 Pegasus II interface, VLAN 401 tagged, 10.3.11.254/24
>         |
>         | Port 9, VLAN 401 tagged
> -------------------
> | Switch          |
> -------------------
>         | Port 3, VLAN 401 untagged
>         |
>         | On board e1000 Ethernet, 10.3.11.223/24
> -------------------
> | Box 2           |
> -------------------
> 
> Pinging box2 from box1 with ping -s 1468 10.3.11.223 works fine, tshark output
> on both boxes identical. Pinging box2 from box1 with ping -s 1469 10.3.11.223
> does not work, echo replies are sent out by box2, but box1 claims to not having
> received them:
> box1$ sudo tshark -i eth3.401 -np
> Running as user "root" and group "root". This could be dangerous.
> Capturing on eth3.401
>   0.000000  10.3.11.254 -> 10.3.11.223  ICMP 1510 Echo (ping) request
>   0.000860  10.3.11.223 -> 10.3.11.254  ICMP 1510 Echo (ping) reply
>   1.003772  10.3.11.254 -> 10.3.11.223  ICMP 1510 Echo (ping) request
>   1.004588  10.3.11.223 -> 10.3.11.254  ICMP 1510 Echo (ping) reply
>   2.007862  10.3.11.254 -> 10.3.11.223  ICMP 1510 Echo (ping) request
>   2.008689  10.3.11.223 -> 10.3.11.254  ICMP 1510 Echo (ping) reply
>   4.808346  10.3.11.254 -> 10.3.11.223  ICMP 1511 Echo (ping) request
>   4.997651 00:12:79:bb:77:0c -> 00:13:3b:00:00:65 ARP 60 Who has 10.3.11.254? 
> Tell 10.3.11.223
>   4.997679 00:13:3b:00:00:65 -> 00:12:79:bb:77:0c ARP 42 10.3.11.254 is at
> 00:13:3b:00:00:65
>   5.808121  10.3.11.254 -> 10.3.11.223  ICMP 1511 Echo (ping) request
>   6.808143  10.3.11.254 -> 10.3.11.223  ICMP 1511 Echo (ping) request
> 
> 
> box2$ sudo tshark -i eth0 -np
>   0.000000  10.3.11.254 -> 10.3.11.223  ICMP 1510 Echo (ping) request
>   0.000457  10.3.11.223 -> 10.3.11.254  ICMP 1510 Echo (ping) reply
>   1.003466  10.3.11.254 -> 10.3.11.223  ICMP 1510 Echo (ping) request
>   1.003492  10.3.11.223 -> 10.3.11.254  ICMP 1510 Echo (ping) reply
>   2.007561  10.3.11.254 -> 10.3.11.223  ICMP 1510 Echo (ping) request
>   2.007586  10.3.11.223 -> 10.3.11.254  ICMP 1510 Echo (ping) reply
>   4.808143  10.3.11.254 -> 10.3.11.223  ICMP 1511 Echo (ping) request
>   4.808167  10.3.11.223 -> 10.3.11.254  ICMP 1511 Echo (ping) reply
>   4.996845 00:12:79:bb:77:0c -> 00:13:3b:00:00:65 ARP 42 Who has 10.3.11.254? 
> Tell 10.3.11.223
>   4.997158 00:13:3b:00:00:65 -> 00:12:79:bb:77:0c ARP 60 10.3.11.254 is at
> 00:13:3b:00:00:65
>   5.807926  10.3.11.254 -> 10.3.11.223  ICMP 1511 Echo (ping) request
>   5.807949  10.3.11.223 -> 10.3.11.254  ICMP 1511 Echo (ping) reply
>   6.807969  10.3.11.254 -> 10.3.11.223  ICMP 1511 Echo (ping) request
>   6.807992  10.3.11.223 -> 10.3.11.254  ICMP 1511 Echo (ping) reply
> 
> All pings get through fine if box1 uses its built-in e1000 interface, so I
> guess it is pretty clear that the Pegasus driver is at fault here - it is not
> alone in this failure, the MCS 7830 driver (see #12003) has the same issue.
> 
> I discussed this on the LKML a few months ago, but unfortunately, without any
> result. I am filing this bug for future reference and do sincerely hope that
> somebody with appropriate knowledge will get around to fix it.
> 
> I can give ssh access to a box which has the device connected. I am also
> prepared to apply, compile and try patches against any recent 2.6 kernel, but
> do not have the expertise (and time) to handle any programming tasks myself.
> 
> Greetings
> Marc

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
