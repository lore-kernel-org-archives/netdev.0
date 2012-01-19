From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 0/3 V3.1] can/usb: Add PEAK-System PCAN USB adapters driver
Date: Thu, 19 Jan 2012 20:08:08 +0100
Message-ID: <4F186A18.6020903@hartkopp.net>
References: <1326968863-20229-1-git-send-email-s.grosjean@peak-system.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-usb Mailing List <linux-usb@vger.kernel.org>,
	netdev Mailing List <netdev@vger.kernel.org>,
	linux-can Mailing List <linux-can@vger.kernel.org>
To: Stephane Grosjean <s.grosjean@peak-system.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1326968863-20229-1-git-send-email-s.grosjean@peak-system.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19.01.2012 11:27, Stephane Grosjean wrote:

> That serie of patches adds the peak_usb driver which handles the PCAN-USB
> and PCAN-USB Pro adapters from PEAK-System (http://www.peak-system.com).
> These patches are planned for kernel v3.02.00 and above.


Hello Stephane,

i tried your patch with Linus' current tree (3.3 merge).

Plugging-in the PEAK USB adapter it turns out to be *very* informative in
the kernel log and also presents information twice:

[  153.566193] usb 2-1.2: new full-speed USB device number 6 using ehci_hcd
[  153.663659] usb 2-1.2: New USB device found, idVendor=0c72, idProduct=000c
[  153.663665] usb 2-1.2: New USB device strings: Mfr=0, Product=3, SerialNumber=0
[  153.663669] usb 2-1.2: Product: VER1:PEAK    
[  153.663671] VER2:02.8.01        
[  153.663672] DAT :06.05.2004
[  153.663672] TIME:09:35:37
[  153.663673]                              ...
[  153.682683] peak_usb: PCAN-USB interfaces driver loaded
[  153.682736] peak_usb 2-1.2:1.0: new PEAK-System usb adapter with 1 can detected:
[  153.682741] peak_usb 2-1.2:1.0: PEAK-System PCAN-USB
[  153.682746] peak_usb 2-1.2:1.0: VER1:PEAK    .VER2:02.8.01        .DAT :06.05.2004.TIME:09:35:37.                             ...
[  153.685422] peak_usb 2-1.2:1.0: serial FFFFFFFF hwrev 28
[  153.686413] peak_usb 2-1.2:1.0: can2 attached to PCAN-USB can 0 (device 46)
[  153.686521] usbcore: registered new interface driver peak_usb

As i assume that this VER2/DAT/TIME stuff and also the "..." line comes
somewhere from the device itself and is printed by the USB stack, i wonder if
we could reduce the information provided by the peak_usb driver then.

E.g.

[  153.682683] peak_usb: PCAN-USB interfaces driver loaded
# is obsolete as peak_usb speaks to us in the following lines

[  153.682736] peak_usb 2-1.2:1.0: new PEAK-System usb adapter with 1 can detected:
[  153.682741] peak_usb 2-1.2:1.0: PEAK-System PCAN-USB
# Can be merged, e.g. to
[  153.682741] peak_usb 2-1.2:1.0: PEAK-System PCAN-USB adapter hwrev 28 (one channel)


[  153.682746] peak_usb 2-1.2:1.0: VER1:PEAK    .VER2:02.8.01        .DAT :06.05.2004.TIME:09:35:37.                             ...
# If you think, this is still needed(???) -> at least kill the spaces like this:
[  153.682746] peak_usb 2-1.2:1.0: VER1:PEAK.VER2:02.8.01.DAT:06.05.2004.TIME:09:35:37....


[  153.685422] peak_usb 2-1.2:1.0: serial FFFFFFFF hwrev 28
[  153.686413] peak_usb 2-1.2:1.0: can2 attached to PCAN-USB can 0 (device 46)
# Can be merged, e.g. to
[  153.686413] peak_usb 2-1.2:1.0: PCAN-USB channel 0 (serial FFFFFFFF, device 46) attached to can2

So it would finally look like this (6 -> 2 lines):

[  153.682741] peak_usb 2-1.2:1.0: PEAK-System PCAN-USB adapter hwrev 28 (one channel)
[  153.686413] peak_usb 2-1.2:1.0: PCAN-USB channel 0 (serial FFFFFFFF, device 46) attached to can2

I'm not sure, if the serial number was identical when having two channels like in the USB-Pro.
If so the serial number in general could be moved up like this:

[  153.682741] peak_usb 2-1.2:1.0: PEAK-System PCAN-USB adapter hwrev 28 serial FFFFFFFF (one channel)
[  153.686413] peak_usb 2-1.2:1.0: PCAN-USB channel 0 (device 46) attached to can2

Btw. thanks for your contribution. You did really big steps in improving your code.
I will do some functional tests now ...

Best regards,
Oliver
