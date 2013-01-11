From: Cedric Jehasse <cedric.jehasse@gmail.com>
Subject: qmi_wwan on Huawei E398
Date: Fri, 11 Jan 2013 13:43:44 +0100
Message-ID: <CABvLYuAX=r_Y0AdDtNp5g0kRYeP6suhLe_b68a7sQYJ-i7wrvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bjorn@mork.no
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f172.google.com ([209.85.220.172]:61817 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409Ab3AKMnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 07:43:45 -0500
Received: by mail-vc0-f172.google.com with SMTP id fw7so1377490vcb.31
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2013 04:43:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to use qmi on an Huawei E398 dongle with ofono on a 3.7.1
kernel. (this works with a 3.5.0 kernel)
ofono looks for the class/subclass/protocol of the parent
usb_interface device for the qmi_wwan and cdc_wdm devices. This must
match with ff/01/08 and ff/01/09 Cls/Sub/Prot.

Below is a trace of the udev events and usb-device output for a 3.5.0
and 3.7.1 kernel. The difference is in the parent devices for wwan0
and cdc-wdm0.
The parent device for wwan0 is on a 3.7.1 kernel is If3. Is this normal?

* 3.5.0:
KERNEL[201.262240] add
/devices/pci0000:00/0000:00:1d.7/usb2/2-6/2-6:1.3/usb/cdc-wdm0 (usb)
KERNEL[201.347292] add
/devices/pci0000:00/0000:00:1d.7/usb2/2-6/2-6:1.4/net/wwan0 (net)

T:  Bus=02 Lev=01 Prnt=01 Port=05 Cnt=01 Dev#=  4 Spd=480 MxCh= 0
D:  Ver= 2.00 Cls=00(>ifc ) Sub=00 Prot=00 MxPS=64 #Cfgs=  1
P:  Vendor=12d1 ProdID=150a Rev=00.00
S:  Manufacturer=Huawei Technologies
S:  Product=HUAWEI Mobile
S:  SerialNumber=1234567890ABCDEF
C:  #Ifs= 7 Cfg#= 1 Atr=c0 MxPwr=500mA
I:  If#= 0 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=01 Prot=01 Driver=option
I:  If#= 1 Alt= 0 #EPs= 2 Cls=ff(vend.) Sub=01 Prot=02 Driver=option
I:  If#= 2 Alt= 0 #EPs= 2 Cls=ff(vend.) Sub=01 Prot=03 Driver=option
I:  If#= 3 Alt= 0 #EPs= 1 Cls=ff(vend.) Sub=01 Prot=09 Driver=cdc_wdm
I:  If#= 4 Alt= 0 #EPs= 2 Cls=ff(vend.) Sub=01 Prot=08 Driver=qmi_wwan
I:  If#= 5 Alt= 0 #EPs= 2 Cls=08(stor.) Sub=06 Prot=50 Driver=usb-storage
I:  If#= 6 Alt= 0 #EPs= 2 Cls=08(stor.) Sub=06 Prot=50 Driver=usb-storage

* 3.7.1:
KERNEL[61750.414019] add
/devices/pci0000:00/0000:00:1d.7/usb2/2-6/2-6:1.3/usbmisc/cdc-wdm0
(usbmisc)
KERNEL[61750.414019] add
/devices/pci0000:00/0000:00:1d.7/usb2/2-6/2-6:1.3/usbmisc/cdc-wdm0
(usbmisc)

T:  Bus=02 Lev=01 Prnt=01 Port=05 Cnt=01 Dev#=  6 Spd=480 MxCh= 0
D:  Ver= 2.00 Cls=00(>ifc ) Sub=00 Prot=00 MxPS=64 #Cfgs=  1
P:  Vendor=12d1 ProdID=150a Rev=00.00
S:  Manufacturer=Huawei Technologies
S:  Product=HUAWEI Mobile
S:  SerialNumber=1234567890ABCDEF
C:  #Ifs= 7 Cfg#= 1 Atr=c0 MxPwr=500mA
I:  If#= 0 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=01 Prot=01 Driver=option
I:  If#= 1 Alt= 0 #EPs= 2 Cls=ff(vend.) Sub=01 Prot=02 Driver=option
I:  If#= 2 Alt= 0 #EPs= 2 Cls=ff(vend.) Sub=01 Prot=03 Driver=option
I:  If#= 3 Alt= 0 #EPs= 1 Cls=ff(vend.) Sub=01 Prot=09 Driver=qmi_wwan
I:  If#= 4 Alt= 0 #EPs= 2 Cls=ff(vend.) Sub=01 Prot=08 Driver=qmi_wwan
I:  If#= 5 Alt= 0 #EPs= 2 Cls=08(stor.) Sub=06 Prot=50 Driver=usb-storage
I:  If#= 6 Alt= 0 #EPs= 2 Cls=08(stor.) Sub=06 Prot=50 Driver=usb-storage

Thanks,
Cedric
