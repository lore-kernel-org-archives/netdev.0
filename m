From: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Tue, 22 Apr 2008 08:29:07 +0200
Message-ID: <480D85B3.1020608@option.com>
References: <20080417214719.GF17664@kroah.com> <480BE815.2000409@teltonika.lt> <200804211016.02819.oliver@neukum.org> <480C5FAF.1050408@teltonika.lt> <20080421184157.106603602C8@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <480D0F5B.9010808@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <480D0F5B.9010808-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Paulius Zaleckas schreef:
> David Brownell wrote:
>>> From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
>>> Date: Mon, 21 Apr 2008 12:34:39 +0300
>>>
>>> IMO it doesn't make sense to do multicasting since actually it is
>>> point-to-point and not ethernet traffic.
>>> Currently I am studying if it is possible to convert current pseudo
>>> ethernet interface to point-to-point one.
>>
>> For the record:  when I looked at that issue with respect to USB
>> network connections for handheld devices, one issue seemed to be
>> weak support for managing (lots of) point-to-point links.
>>
>> The example that sticks in my memory is that of routing.  Setting
>> up a point to point link between a handheld and a PC required
>> the PC to act as an IP router.  Managing lots of desktop routers
>> in any large configuration seemed to be a losing game ... and
>> one that many network administrators would refuse to play.  And
>> that's in addition to the lack of a dynamic IP address assignment
>> solution for lots of point-to-point links.
>>
>> The alternative was to set up the links like Ethernet, then bridge
>> them.  That's a *much* more manageable solution, even though I still
>> don't know of any distro that makes bridge setup work as easily as
>> Windows does (sigh).  Bridging properly requires the ability to handle
>> multicast and broadcast packets ... and once you've got that then
>> DHCP, zeroconf, and other automatic network configuration schemes
>> work easily.
>>
>> QED ... that's why the "usbnet" framework doesn't try to use the
>> point-to-point framework, instead allows N-casting.
>>
>> - Dave
> 
> I would agree with you, but... To make this interface work you have to
> send AT command with APN and optionally with PAP/CHAP username and 
> password.
> Then you call AT command witch initiates PPP with basestation and begins
> to send/receive traffic on this pseudo ethernet interface... Actually it
> still needs one more AT command to get your IP and DNS addresses.
> Then you do: ifconfig hso0 xxx.xxx.xxx.xxx netmask 255.255.255.255 up
> And then you have to write DNS addresses (got through AT interface) to
> the /etc/resolv.conf. Now you have a working internet connection!
> 
> So... I don't see any chance to do multicasting or broadcasting here...
> IMO the only way to distribute this kind of connection to local network
> is to do NAT'ing :( Am I wrong?
> 
> P.S. Pseudo ethernet means that it receives bare IP packet from USB device,
> adds dummy ethernet header and sends it for further processing to kernel.

Correct. And we don't support DHCP.

Filip-
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
