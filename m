From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: ieee80211 patches
Date: Fri, 26 Aug 2005 19:50:47 -0400
Message-ID: <200508261950.47716.flamingice@sourmilk.net>
References: <20050825193112.529d0dc9@griffin.suse.cz> <200508261107.07501.flamingice@sourmilk.net> <20050826181329.6dcf94d3@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, NetDev <netdev@vger.kernel.org>,
        Jeff Garzik <jgarzik@pobox.com>, jbohac@suse.cz, pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050826181329.6dcf94d3@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 26 August 2005 12:13, Jiri Benc wrote:
> You mentioned problem with hooks in scanning/association/etc. Probably
> everybody involved in this discussion knows it but I think it is worth
> saying it: This is one of the most important things in a new ieee80211
> layer. Unfortunately, it seems that every driver developer concentrates
> on the aspects of his device (this include ieee80211 layer from ipw as
> well as from rtl8180). But every device (or more precisely firmware)
> provides different set of features - some takes care of almost
> everything, other can do basic things only. So the amount of work that
> needs to be done in the ieee80211 layer is different for different
> devices. The layer has to be generic. It has to cope e.g. with
> authentication/association performed fully by itself as well as with
> auth/assoc performed automatically by the device, etc.
>
> I'm convinced this is the first goal we have to reach before we start to
> implement WPA, QoS and so.
Right now, the adm8211 driver uses a number of specific hooks in its own 
ieee80211 station management code such as:

set_bssid
set_ssid
set_channel
set_interval
set_beacon

Though with enough of these hooks, many devices can be supported, I think 
generic hooks like these would work best to support a wide range of hardware 
that use softmac:

pre_scan
set_channel
pre_associate
link_change
start_ibss
join_ibss

Then for the devices that do more in the firmware, adding callbacks like:

hw_scan
hw_associate
hw_start_ibss

would indicate to the ieee80211 layer that the hardware is capable of handling 
those things itself.

The driver should be able to find all the info needed to configure the 
hardware in ieee80211_device so only that needs to be passed to the hooks.

A good portion of WPA can be implemented right now by implementing the 
encodeext ioctls and generalizing ieee80211_security to support more than 
just WEP. adm8211 doesn't have support for non-wep encryption yet, so WPA 
works without ieee80211_security support.

Sound good?

-Michael Wu
