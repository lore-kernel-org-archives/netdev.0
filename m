From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: e1000: driver reboot/kexec bug.
Date: Thu, 17 Feb 2005 09:02:00 -0800
Message-ID: <468F3FDA28AA87429AD807992E22D07E044A1285@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <jgarzik@pobox.com>,
        "Chilakala, Mallikarjuna" <mallikarjuna.chilakala@intel.com>,
        <netdev@oss.sgi.com>
Content-class: urn:content-classes:message
To: <eric@ebiederm.dsl.xmission.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Eric:

Could you send us 'lspci -vvv' output for 3:4.0? Could you also help us
with some more information on the platform you are using?

Thanks,
Ganesh.

>-----Original Message-----
>From: eric@ebiederm.dsl.xmission.com
>[mailto:eric@ebiederm.dsl.xmission.com] On Behalf Of Eric W. Biederman
>Sent: Wednesday, February 16, 2005 4:26 AM
>To: Chilakala, Mallikarjuna
>Cc: jgarzik@pobox.com; netdev
>Subject: e1000: driver reboot/kexec bug.
>
>
>When I kexec a new kernel on hardware that includes
>some revs of the e1000 (see below for lscpi -n) the
>e1000 driver is not able to reinitialize the NIC.  I
>have seen this in both 2.4.29 and 2.6.10.
>
>Tracking it down it appears to be some side effect to powering down
>the nic.  If I remove the pci_set_power_state call in e1000_suspend
>or I simply apply the attached patch so I get that affect when
>rebooting everything works.  pci_enable_device brings the device
>up to full power before the driver initialization code does anything
>else so I don't have a clue what is really going on but it is.
>
>
>Boot messages on failure:
>> Intel(R) PRO/1000 Network Driver - version 5.6.10.1-k1
>> Copyright (c) 1999-2004 Intel Corporation.
>> PCI: Enabling device 03:04.0 (0000 -> 0003)
>> e1000: 03:04.0: e1000_probe: The EEPROM Checksum Is Not Valid
>> PCI: Enabling device 03:04.1 (0000 -> 0003)
>> e1000: 03:04.1: e1000_probe: The EEPROM Checksum Is Not Valid
>
>lspci -n of the problem onboard e1000 NIC.
>> 03:04.0 Class 0200: 8086:1079 (rev 03)
>> 03:04.1 Class 0200: 8086:1079 (rev 03)
>
>
>Patch which avoids the problem.
>diff -uNrX linux-exclude-files linux-2.4.29-kexec-apic-virtwire-on-
>shutdownx86_64/drivers/net/e1000/e1000_main.c linux-2.4.29-
>kexec7.build.x86_64/drivers/net/e1000/e1000_main.c
>--- linux-2.4.29-kexec-apic-virtwire-on-
>shutdownx86_64/drivers/net/e1000/e1000_main.c	Tue Feb 15 14:17:09 2005
>+++ linux-2.4.29-kexec7.build.x86_64/drivers/net/e1000/e1000_main.c
Wed
>Feb 16 04:58:18 2005
>@@ -2777,7 +2777,7 @@
> 	case SYS_POWER_OFF:
> 		while((pdev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID,
pdev))) {
> 			if(pci_dev_driver(pdev) == &e1000_driver)
>-				e1000_suspend(pdev, 3);
>+				e1000_suspend(pdev, (event ==
SYS_DOWN)?0:3);
> 		}
> 	}
> 	return NOTIFY_DONE;
>
>
>Any help to track down why this is happening so we can apply
>a clean fix would be appreciated.
>
>Eric
