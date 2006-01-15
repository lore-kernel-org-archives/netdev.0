From: Sam Leffler <sam@errno.com>
Subject: Re: wireless: recap of current issues (configuration)
Date: Sun, 15 Jan 2006 12:08:52 -0800
Message-ID: <43CAABD4.3070004@errno.com>
References: <20060113195723.GB16166@tuxdriver.com> <200601151340.10730.stefan@loplof.de> <56187.84.135.205.30.1137340292.squirrel@secure.sipsolutions.net> <200601151853.31710.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932138AbWAOUKN@vger.kernel.org>
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200601151853.31710.stefan@loplof.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stefan Rompf wrote:
> Am Sonntag 15 Januar 2006 16:51 schrieb Johannes Berg:
> 
>> Isn't that rather a question of having good user-space tools that make
>> deactivating one type of interface and activating another seamless?
> 
> Well, it's always easy to point to userspace. However, unregister_netdev() 
> initiates a lot of actions. IPv4 addresses and routes are removed, same for 
> IPv6, IPX, Appletalk etc. Stacked VLAN devices are recursively unregistered 
> (even though I have not tried yet if it works when I create VLANs over 802.3 
> emulated wlan interfaces ;-), udev bloat runs. And all this stuff has to be 
> restored by the nifty new configuration utility, possibly including ifindex 
> and future protocols.
> 
> This is from my usage pattern that I want to go into monitor mode on current 
> channel, look at some packets and return to the association without losing 
> layer 3 configuration.
> 
> So after all, it is IMHO way less painful to handle a mode change in the 
> kernel.

To do what you describe I would create a monitor mode device, switch 
channel, then destroy it.  All the time you leave the station device 
unchanged, though you probably need to disable it.  This may not be 
possible with all devices--i.e. for those that require different 
firmware to do monitoring you will be restricted to a single virtual 
device and/or operating mode.

	Sam
