From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] Add firmware label support to iproute2
Date: Fri, 27 Aug 2010 09:54:34 +0200
Message-ID: <AANLkTi=xgNPueEBiJ6R8E0D2LRnOFggVAJ17KZtDG3Lw@mail.gmail.com>
References: <20100812173537.GA29784@auslistsprd01.us.dell.com>
 <20100812141240.417949e2@s6510> <EDA0A4495861324DA2618B4C45DCB3EE612E34@blrx3m08.blr.amer.dell.com>
 <20100818144124.33a72453@nehalam> <20100819213314.GA26135@auslistsprd01.us.dell.com>
 <20100819145308.0fa08522@nehalam> <20100825220323.GA12671@auslistsprd01.us.dell.com>
 <20100825171646.3d40b721@nehalam> <20100826150116.GB21770@auslistsprd01.us.dell.com>
 <D3F292ADF945FB49B35E96C94C2061B90CEAD321@nsmail.netscout.com>
 <20100826082138.76bcd315@nehalam> <D3F292ADF945FB49B35E96C94C2061B90CEAD362@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Matt Domsch <Matt_Domsch@dell.com>, Narendra_K@dell.com,
	netdev@vger.kernel.org, Charles_Rose@dell.com,
	Jordan_Hargrave@dell.com, linux-pci@vger.kernel.org,
	linux-hotplug@vger.kernel.org
To: "Loke, Chetan" <Chetan.Loke@netscout.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90CEAD362@nsmail.netscout.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 26, 2010 at 17:38, Loke, Chetan <Chetan.Loke@netscout.com> =
wrote:
> Sorry, my bad.
> I agree w/ your recommendation then -
> 1) stuff it in ifalias(or create a new alias if net_device::ifalias i=
s
> used for snmp etc).
>
> But how do we consume it?
> =C2=A0 1.1) spit it out via sysfs? But Doc/sysfsrules.txt says "Acces=
sing
> /sys/class/net/eth0/device is a bug in the application"

You walk up the parent devices of the netdev until you find the one
you are looking for. The "device" link is broken by design and might
just point to the first parent device. The kernel is free to insert
devices into the device tree if needed, and then the device link
target may change.

/sys/class/net/eth0 is a symlink pointing to a location the
/sys/devices tree, like:
  ../../devices/pci0000:00/0000:00:19.0/net/eth0
One of the parent devices of the eth0 device has this attribute., but
you can never be sure that it's just the next parent (broken concept
of the device link), you have to walk up the chain of parents.

You can just use udev to that automatically and extract the value, and
pass it with the event for the eth0 device.

Kay
