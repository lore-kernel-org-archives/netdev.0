From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: rfkill regression in net-next-2.6
Date: Sun, 14 Jun 2009 11:17:47 +0200
Message-ID: <4A34C03B.4030909@hartkopp.net>
References: <20090604152011.GC2839@tuxdriver.com>	 <20090607.033751.191866033.davem@davemloft.net>	 <4A2BCC41.1060508@hartkopp.net> <20090607145830.GA2736@tuxdriver.com>	 <4A2BD8A5.4040302@hartkopp.net> <1244388583.23850.87.camel@localhost.localdomain> <4A34BAB9.9000104@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4A34BAB9.9000104-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I missed the Dell dcdbas log output that seems to kill the LED ...
see below.

Oliver Hartkopp wrote:
> Marcel Holtmann wrote:
> 
>> compiling RFKILL itself as a module is still working perfectly fine. It
>> is just the RFKILL_INPUT that can't be built as a module anymore. That
>> part was pointless anyway. And in the future RFKILL_INPUT will go away
>> and be replaced by a userspace implementation with proper support for
>> platform specific policies.
> 
> Hi all,
> 
> i have a Dell Lattitude 830 with Bluetooh and b43 WLAN and my RFKILL-switch is
> set to ON.
> 
> On power on the BT LED is on and when booting with 2.6.30 or with 2.6.30-git5
> the WLAN LED becomes illuminated within the boot process after b43 pulled his
> firmware.
> 
> With net-next-2.6 the BT LED is switched OFF(!) during the boot process and
> the Kernel log says:
> 
> [   15.276568] b43 ssb0:0: firmware: requesting b43/b0g0bsinitvals5.fw
> [   15.423540] b43-phy0: Loading firmware version 410.2160 (2007-05-26 15:32:10)
> [   15.545096] b43-phy0 debug: Chip initialized
> [   15.545317] b43-phy0 debug: 32-bit DMA initialized
> [   15.566383] b43-phy0 debug: Wireless interface started
> [   15.566394] b43-phy0 debug: Adding Interface type 2
> [   15.566670] b43-phy0: Radio hardware status changed to DISABLED
> [   15.633069] b43-phy0: Radio turned on by software
> [   15.647094] b43-phy0: The hardware RF-kill button still turns the radio
> physically off. Press the button to turn it on.
> [   15.673598] ADDRCONF(NETDEV_UP): wlan0: link is not ready
> [   15.721053] b43-phy0 debug: Removing Interface type 2
> [   15.733877] b43-phy0 debug: Wireless interface stopped
> 
> The WLAN LED is never illuminated with net-next-2.6.
> 
> The BT LED is switched off something around this time in the log:


[    4.079342] usb 7-1.2: configuration #1 chosen from 1 choice
[    6.663535] dcdbas dcdbas: Dell Systems Management Base Driver (version
5.6.0-3.2)
[    7.097116] usb 3-2: USB disconnect, address 2
[    7.623369] Bluetooth: Core ver 2.15
[    7.639047] NET: Registered protocol family 31

> 
> [    7.639047] NET: Registered protocol family 31
> [    7.651562] Bluetooth: HCI device and connection manager initialized
> [    7.664155] Bluetooth: HCI socket layer initialized
> [    7.756113] b43-pci-bridge 0000:0c:00.0: PCI INT A -> GSI 17 (level, low)
> -> IRQ 17
> [    7.769117] b43-pci-bridge 0000:0c:00.0: setting latency timer to 64
> [    7.828160] yenta_cardbus 0000:03:01.0: CardBus bridge found [1028:01fe]
> [    7.841107] yenta_cardbus 0000:03:01.0: O2: res at 0x94/0xD4: 00/ea
> [    7.853830] yenta_cardbus 0000:03:01.0: O2: enabling read prefetch/write burst
> [    7.867428] i801_smbus 0000:00:1f.3: PCI INT B -> GSI 17 (level, low) -> IRQ 17
> [    7.881369] ssb: Sonics Silicon Backplane found on PCI device 0000:0c:00.0
> [    7.897694] Bluetooth: Generic Bluetooth USB driver ver 0.5
> [    7.910910] usbcore: registered new interface driver btusb
> 
> 
> When i see the BT LED switching to off, i can manually switch the RFKILL
> switch to OFF and ON, and then both LEDs get illuminated and WLAN is
> successfully initialized by the boot process.
> 
> As we discussed about RFKILL and modules, i set CONFIG_RFKILL=y in my
> net-netx-2.6 tree with no change of the behaviour.
> 
> Any idea what changed in net-next-2.6 that could produce this behaviour?
> 
> Regards,
> Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
