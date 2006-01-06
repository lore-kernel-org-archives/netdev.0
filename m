From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: State of the Union: Wireless
Date: Fri, 6 Jan 2006 12:46:20 +0100
Message-ID: <20060106114620.GA23707@isilmar.linta.de>
References: <20060106042218.GA18974@havoc.gtf.org> <1136547084.4037.41.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751314AbWAFLqW@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1136547084.4037.41.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 06, 2006 at 12:31:24PM +0100, Johannes Berg wrote:
> On Fri, 2006-01-06 at 12:00 +0100, Michael Buesch wrote:
> 
> > * "master" interface as real device node
> > * Virtual interfaces (net_devices)
> 
> I didn't want to spam the netdev wiki with this (yet) so I collected
> some more structured things outside. Anyone feel free to edit:
> http://softmac.sipsolutions.net/802.11

>From someone who has no idea at all (yet) about 802.11: why character
device, and not sysfs or configfs files? Like

TASK: get list of MAC addresses available to hardware device (usually only one for current hw)

cat /sys/devices/path/to/device/wireless/address

TASK: get list of virtual devices including (some of) their properties

ls -l /sys/devices/path/to/device/wireless/
	...
	wlan0 -> /sys/class/net/wlan0
	wlan1 -> /sys/class/net/wlan1

TASK: create virtual device (with arbitrary type, netdev name and mac address)
						  ^^^^^^
					   isn't nameif / udev for that?

echo "$type" > /sys/devices/path/to/device/wireless/new_if
	... we get uevents for this new interface; in this we can set the
	mac adress doing:
echo "$mac" > /sys/class/net/wlan0/wireless/address

TASK: configure virtual device (key is the device name since that needs to be unique anyway) 

echo "$some_config_option_for_virtual_device" > /sys/class/net/wlan0/wireless/some_option
echo "$some_config_option_for_physical_device"> /sys/devices/path/to/dev/wireless/some_other_option


Of course the configuration userspace tool would use libsysfs for that, not
"echo" scripts... but they'd work too.

	Dominik
