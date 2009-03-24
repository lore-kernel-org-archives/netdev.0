From: Patrick McHardy <kaber@trash.net>
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 17:21:16 +0100
Message-ID: <49C9087C.5070907@trash.net>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20090324154617.GA16332@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Domsch wrote:
> 2) udev may have rules to change the device names.  This is most often
>    seen in the '70-persistent-net.rules' file.  Here we have
>    additional challenges:
> 
> ...
> 
>    c) udev may not always be able to change a device's name.  If udev
>       uses the kernel assignment namespace (ethN), then a rename of
>       eth0->eth1 may require renaming eth1->eth0 (or something else).
>       Udev operates on a single device instance at a time, it becomes
>       difficult to switch names around for multiple devices, within
>       the single namespace.

I would classify this as a bug, especially the fact that udev doesn't
undo a failed rename, so you end up with ethX_rename. Virtual devices
using the same MAC address trigger this reliably unless you add
exceptions to the udev rules.

You state that it only operates on one device at a time. If that is
correct, I'm not sure why the _rename suffix is used at all instead
of simply trying to assign the final name, which would avoid this
problem.
