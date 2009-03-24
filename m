From: David Miller <davem@davemloft.net>
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 15:57:56 -0700 (PDT)
Message-ID: <20090324.155756.214460004.davem@davemloft.net>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matt_Domsch@dell.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20090324154617.GA16332@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Domsch <Matt_Domsch@dell.com>
Date: Tue, 24 Mar 2009 10:46:17 -0500

> Problem: Users expect on-motherboard NICs to be named eth0..ethN.
> This can be difficult to achieve.

I learned a long time ago that eth0 et al. have zero meaning.

If the system firmware folks gave us topology information with respect
to these things, we could export something that tools such as
NetworkManager, iproute2, etc. could use.

For example, if we were told that PCI device "domain:bus:dev:fn" has
string label "Onboard Ethernet 0" then we could present that to the
user.

Changing how the actual network device name is determined is going to
have zero traction.

So, please, put mapping tables into the ACPI or similar and then
programs can go:

	for_each_network_device(name) {
		fd = open(name);
		label = get_system_label(fd, name);
		present_to_user(label, name);
	}

This "get_system_label()" thing can be an ethtool ioctl, some
rtnetlink call, or similar.  In the kernel, a generic routine would
exist for major bus types to make the mapping translation, and drivers
would call these.

For PCI it might take the PCI device pointer and try to fish
out a string from the ACPI layer.

For OpenFirmware we might just simply give the full device path,
or a matching device alias name.

That's the only model which allows a smooth transition and
no major infrastructure changes.

I guess it's easier to spew about MAC addresses and other
irrelevant topics than try to solve this problem properly. :-)
