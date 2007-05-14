From: Florin Malita <fmalita@gmail.com>
Subject: [PATCH 15/17] sky2: only disable 88e8056 on some boards
Date: Mon, 14 May 2007 00:53:42 -0400
Message-ID: <4647EB56.6080800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:25381 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754352AbXENEzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 00:55:10 -0400
Received: by an-out-0708.google.com with SMTP id d18so385563and
        for <netdev@vger.kernel.org>; Sun, 13 May 2007 21:55:09 -0700 (PDT)
References: 20070509035030.939143538@linux-foundation.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Stephen Hemminger wrote:
> Use DMI to add a blacklist of broken board. For now only one is known
> bad. Gentoo users report driver works on other motherboards (strange). 
[snip]
> +               .ident = "Gigabyte 965P-S3",
> +               .matches = {
> +                       DMI_MATCH(DMI_SYS_VENDOR, "Gigabyte Technology Co., 
> Ltd."),
> +                       DMI_MATCH(DMI_PRODUCT_NAME, "965P-S3"),

Actually, I've been using sky2 with a 965P-S3 for a couple of months 
(x86_64 kernel) and as far as I can tell it works like a charm. Recently 
I had to hack around the blacklisting but other than that I haven't 
noticed anything strange.

What failures are you trying to prevent? Would a warning (instead of 
blacklisting) be acceptable?

Thanks,
Florin

04:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller (rev 12)
	Subsystem: Giga-byte Technology Unknown device e000
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 315
	Region 0: Memory at f5000000 (64-bit, non-prefetchable) [size=16K]
	Region 2: I/O ports at 9000 [size=256]
	[virtual] Expansion ROM at 80000000 [disabled] [size=128K]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
	Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
		Address: 00000000fee00000  Data: 40d9
	Capabilities: [e0] Express Legacy Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s unlimited, L1 unlimited
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 0
		Link: Latency L0s <256ns, L1 unlimited
		Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
	Capabilities: [100] Advanced Error Reporting
00: ab 11 64 43 07 04 10 00 12 00 00 02 08 00 00 00
10: 04 00 00 f5 00 00 00 00 01 90 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 58 14 00 e0
30: 00 00 00 00 48 00 00 00 00 00 00 00 0b 01 00 00

# dmidecode 2.7
SMBIOS 2.4 present.
39 structures occupying 1192 bytes.
Table at 0x000F0100.

Handle 0x0000, DMI type 0, 24 bytes.
BIOS Information
	Vendor: Award Software International, Inc.
	Version: F8
	Release Date: 01/11/2007
	Address: 0xE0000
	Runtime Size: 128 kB
	ROM Size: 1024 kB
	Characteristics:
		PCI is supported
		PNP is supported
		APM is supported
		BIOS is upgradeable
		BIOS shadowing is allowed
		Boot from CD is supported
		Selectable boot is supported
		EDD is supported
		5.25"/360 KB floppy services are supported (int 13h)
		5.25"/1.2 MB floppy services are supported (int 13h)
		3.5"/720 KB floppy services are supported (int 13h)
		3.5"/2.88 MB floppy services are supported (int 13h)
		Print screen service is supported (int 5h)
		8042 keyboard services are supported (int 9h)
		Serial services are supported (int 14h)
		Printer services are supported (int 17h)
		CGA/mono video services are supported (int 10h)
		ACPI is supported
		USB legacy is supported
		LS-120 boot is supported
		ATAPI Zip drive boot is supported
		BIOS boot specification is supported
		Targeted content distribution is supported

Handle 0x0001, DMI type 1, 27 bytes.
System Information
	Manufacturer: Gigabyte Technology Co., Ltd.
	Product Name: 965P-S3
	Version:  
	Serial Number:  
	UUID: 00000000-0000-0000-0000-0016E6D4022E
	Wake-up Type: Power Switch
	SKU Number:  
	Family:  

Handle 0x0002, DMI type 2, 8 bytes.
Base Board Information
	Manufacturer: Gigabyte Technology Co., Ltd.
	Product Name: 965P-S3
	Version:  
	Serial Number:  

Handle 0x0003, DMI type 3, 17 bytes.
Chassis Information
	Manufacturer: Gigabyte Technology Co., Ltd.
	Type: Desktop
	Lock: Not Present
	Version:  
	Serial Number:  
	Asset Tag:  
	Boot-up State: Unknown
	Power Supply State: Unknown
	Thermal State: Unknown
	Security Status: Unknown
	OEM Information: 0x00000000

Handle 0x0004, DMI type 4, 35 bytes.
Processor Information
	Socket Designation: Socket 775
	Type: Central Processor
	Family: Other
	Manufacturer: Intel
	ID: F2 06 00 00 FF FB EB BF
	Version: Intel(R) Core(TM)2 CPU 640
	Voltage: 1.3 V
	External Clock: 384 MHz
	Max Speed: 4000 MHz
	Current Speed: 3072 MHz
	Status: Populated, Enabled
	Upgrade: Socket 478
	L1 Cache Handle: 0x000A
	L2 Cache Handle: 0x000B
	L3 Cache Handle: Not Provided
	Serial Number:  
	Asset Tag:  
	Part Number:  



