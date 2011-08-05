From: Tom London <selinux@gmail.com>
Subject: Re: return of ip_rt_bug()
Date: Fri, 5 Aug 2011 06:18:06 -0700
Message-ID: <CAFiZG+Wmv_FEx2ZX3qZt0tAr-QVQD_javX1gbRWujr9xyf7nbQ@mail.gmail.com>
References: <20110802170942.GA17164@redhat.com>
	<alpine.LFD.2.00.1108041422510.1495@ja.ssi.bg>
	<CAFiZG+X0oyTOXqm4b0g_UEGYK_0JCW3=WOR5d_7GfbJrTMhMzg@mail.gmail.com>
	<alpine.LFD.2.00.1108042034540.1495@ja.ssi.bg>
	<CAFiZG+W9-vV6o9EbuVEwztW4sQ1QV-MxD+xCHFw7TbNAryzN6A@mail.gmail.com>
	<CAFiZG+UY+Rn=wqi6b9CM0CcARHJUGiqh_jpfEveGLhm+D2hNhA@mail.gmail.com>
	<alpine.LFD.2.00.1108051048160.1494@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:41414 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753914Ab1HENSH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 09:18:07 -0400
Received: by qyk38 with SMTP id 38so302871qyk.19
        for <netdev@vger.kernel.org>; Fri, 05 Aug 2011 06:18:06 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1108051048160.1494@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 5, 2011 at 12:56 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
> =A0 =A0 =A0 =A0Hello,
>
> On Thu, 4 Aug 2011, Tom London wrote:
>
>> So, my router is just giving my wired NIC different addresses....
>>
>> More I can provide?
>
> =A0 =A0 =A0 =A0Thanks! Can you check in dmesg or in another log
> about the first IP address in such line:
>
> printk(KERN_DEBUG "ip_rt_bug: %pI4 -> %pI4, %s\n"
>
> =A0 =A0 =A0 =A0Is it now 192.168.2.6 ?
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>

Sorry, don't see those messages.  I guess I'll have to reboot with
'debug' to see that.

Before I do that, I booted this time with the RFKILL switch set to
kill the radio (both BT and WIFI), and reran the above tests.

Here is what 'ip monitor' said:

[root@tlondon ~]# ip monitor
192.168.2.1 dev eth0 lladdr 00:1c:df:e2:3e:e9 STALE
192.168.2.1 dev eth0 lladdr 00:1c:df:e2:3e:e9 REACHABLE
192.168.2.1 dev eth0 lladdr 00:1c:df:e2:3e:e9 STALE
192.168.2.1 dev eth0 lladdr 00:1c:df:e2:3e:e9 STALE
ff02::fb via ff02::fb dev eth0  metric 0
    cache
192.168.2.1 dev eth0 lladdr 00:1c:df:e2:3e:e9 STALE

Here is what 'inotail -f /var/log/messages' said:


Aug  5 06:12:21 tlondon kernel: [  536.727187] usb 3-1: new full speed
USB device number 2 using uhci_hcd
Aug  5 06:12:21 tlondon kernel: [  537.315296] usb 3-1: New USB device
found, idVendor=3D04b8, idProduct=3D010a
Aug  5 06:12:21 tlondon kernel: [  537.315308] usb 3-1: New USB device
strings: Mfr=3D1, Product=3D2, SerialNumber=3D0
Aug  5 06:12:21 tlondon kernel: [  537.315317] usb 3-1: Product: Perfec=
tion1640
Aug  5 06:12:21 tlondon kernel: [  537.315323] usb 3-1: Manufacturer: E=
PSON
Aug  5 06:12:21 tlondon mtp-probe: checking bus 3, device 2:
"/sys/devices/pci0000:00/0000:00:1a.0/usb3/3-1"
Aug  5 06:12:22 tlondon mtp-probe: bus: 3, device: 2 was not an MTP dev=
ice

So, no WARN_ON messages.

I'd like to conclude that this is due to UDP casting on the wlan.
I'll reboot with the radio on and in debug mode to see what happens.

tom
--=20
Tom London
