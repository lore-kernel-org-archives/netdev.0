From: Richard Yao <ryao@gentoo.org>
Subject: How do I update Ericsson F5521gw firmware from Linux? / Ericsson
 F5521gw Random Disconnect Issue
Date: Wed, 3 Dec 2014 10:58:41 +0000
Message-ID: <20141203105841.GF32286@woodpecker.gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:33013 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751374AbaLCK6l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 05:58:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I purchased an Ericsson F5521gw (Lenovo part 60Y3279) so that my Lenovo T520
could connect to China Unicom for internet access during a stay in China.
Unfortunately, it tends to fail every 4 to 8 hours with the following printed
to the system log:

Dec  3 04:28:27 t520 kernel: [85827.909187] cdc_ncm 2-1.4:1.6 wwan0: network connection: disconnected
Dec  3 04:28:27 t520 NetworkManager[4134]: <info> (ttyACM1): modem state changed, 'connected' --> 'registered' (reason: user-requested)
Dec  3 04:28:27 t520 NetworkManager[4134]: <info> (ttyACM1): device state change: activated -> failed (reason 'modem-no-carrier') [100 120 25]
Dec  3 04:28:27 t520 NetworkManager[4134]: <info> NetworkManager state is now CONNECTED_LOCAL
Dec  3 04:28:27 t520 NetworkManager[4134]: <info> NetworkManager state is now CONNECTED_GLOBAL
Dec  3 04:28:27 t520 NetworkManager[4134]: <info> Policy set 'tun0' (tun0) as default for IPv4 routing and DNS.
Dec  3 04:28:27 t520 dbus[3912]: [system] Activating service name='org.freedesktop.nm_dispatcher' (using servicehelper)
Dec  3 04:28:27 t520 nm-openvpn[4200]: MANAGEMENT: Client disconnected
Dec  3 04:28:27 t520 nm-openvpn[4200]: SIGTERM received, sending exit notification to peer
Dec  3 04:28:27 t520 NetworkManager[4134]: <info> (tun0): link disconnected (deferring action for 4 seconds)
Dec  3 04:28:27 t520 NetworkManager[4134]: <error> [1417598907.695056] [platform/nm-linux-platform.c:1714] add_object(): Netlink error adding 0.0.0.0/0 via 10.8.0.5 dev tun0 metric 1024 mss 0 src user: Unspecific failure
Dec  3 04:28:27 t520 NetworkManager[4134]: <error> [1417598907.695124] [platform/nm-linux-platform.c:1714] add_object(): Netlink error adding 10.8.0.5/32 via 0.0.0.0 dev tun0 metric 1024 mss 0 src user: Unspecific failure
Dec  3 04:28:27 t520 NetworkManager[4134]: <error> [1417598907.695165] [platform/nm-linux-platform.c:1714] add_object(): Netlink error adding 0.0.0.0/0 via 10.8.0.5 dev tun0 metric 1024 mss 0 src user: Unspecific failure
tail: /var/log/messages: file truncated
Dec  3 04:28:27 t520 NetworkManager[4134]: <error> [1417598907.695165] [platform/nm-linux-platform.c:1714] add_object(): Netlink error adding 0.0.0.0/0 via 10.8.0.5 dev tun0 metric 1024 mss 0 src user: Unspecific failure
Dec  3 04:28:27 t520 NetworkManager[4134]: <error> [1417598907.695187] [nm-policy.c:693] update_ip4_routing(): Failed to set default route.
Dec  3 04:28:27 t520 NetworkManager[4134]: <warn> Activation (ttyACM1) failed for connection 'China Unicom'
Dec  3 04:28:27 t520 NetworkManager[4134]: <info> (ttyACM1): device state change: failed -> disconnected (reason 'none') [120 30 0]
Dec  3 04:28:27 t520 NetworkManager[4134]: <info> (ttyACM1): deactivating device (reason 'none') [0]
Dec  3 04:28:27 t520 dbus[3912]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher'
Dec  3 04:28:27 t520 nm-dispatcher: Dispatching action 'vpn-down' for tun0
Dec  3 04:28:27 t520 nm-dispatcher: Dispatching action 'down' for wwan0

Here is the modem's description of itself:

mmcli -m 0 --command='AT*EEVINFO=99'
response: '*EEVINFO:
Model.................... F5521gw
IMEI Data................ <REDACTED>
SVN...................... 05
Serial Number............ <REDACTED>
Product Number........... KRD 131 18/221
Revision................. R1C
FW Product............... CXP 901 7640/1
FW Version............... R2A07
FW Build Date/Time....... 2010-12-03/12:17
Cust. Product............ CXC 173 0424/22
Cust. Version............ R1B02
Customization Descr...... Lenovo
Format................... 1
Base Product Number...... 1/KRD 131 18/1
Base Product Revision.... R1N
SIMLock Deployment....... 0.0
SIMLock Description...... Unlocked
SIMLock Product.......... CXC 173 0839/01
SIMLock Revision......... R1F
Model Description........ F5521gw Mobile Broadband Module
Vendor Name.............. Lenovo
Config. Set Product...... CXP 901 7629/1
Config. Set Revision..... R3A02
Network Customization.... Default;46001
Customization State...... 0
Configuration Product.... CXP 901 7640/1
Configuration Revision... R2A07
Protocol FW Product...... CXC 173 0063/1
Protocol FW Version...... R2A07
Application FW Product... CXC 173 0064/1
Application FW Version... R2A07
Network List Product..... CXC 173 1116/1
Network List Revision.... R1A
Individualization........ 189.191
Domain................... 3.3
Upgrade State............ 1
Volume info.............. 66 MB total / 43.9% free'

Posts on the Lenovo forums suggest that this can be resolved by updating the
firmware:

http://forums.lenovo.com/t5/X-Series-Tablet-ThinkPad-Laptops/Ericsson-F5521gw-WWAN-disconnects-intermittently-and-cannot/td-p/565597

Unfortunately, the official firmware updater only runs on Windows and I am
unable to find a way to update the firmware from Linux. I also cannot find any
hardware documentation. Does anyone have any suggestions?
