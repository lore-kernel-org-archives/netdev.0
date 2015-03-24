From: "Boylan, Ross" <Ross.Boylan@ucsf.edu>
Subject: slow networking with VM virtio
Date: Tue, 24 Mar 2015 19:37:42 +0000
Message-ID: <F1F13E14A610474196571953929C020969A1DD@ex08.net.ucsf.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [68.232.143.34] ([68.232.143.34]:33668 "EHLO
	esa2.ucsf.iphmx.com" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752374AbbCXTpm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 15:45:42 -0400
Received: from EXHT01.net.ucsf.edu (mx.ucsf.edu [64.54.247.193]) by bcuda4.ucsf.edu with ESMTP id iTVnMEmu7BX2LmAf (version=TLSv1 cipher=AES128-SHA bits=128 verify=NO) for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 12:37:54 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running a Windows 7 VM under KVM, with virtio drivers, the networking was so slow as to be non-functional.
As suggested in comment 11 of  https://bugzilla.redhat.com/show_bug.cgi?id=855640, I did ethtool -K eth1 gro off and speeds got much better, ~150Mb/s, although using speedtest.net it was unable to connect to the server for the upload test.

However, ssh in to the host machine, or to linux VM's running on the same host, became extremely erratic (prone to dropped connections) and slow after making these changes.  I was connected via sshuttle for VPN.

Does anyone have any suggestions?
I would appreciate a cc.

Thanks.
Ross Boylan

Details:
Host is running Debian wheezy on amd64.  Using virt-manager > libvirt > kvm and bridged networking.
Linux markov00 3.2.0-4-amd64 #1 SMP Debian 3.2.65-1+deb7u2 x86_64 GNU/Linux
Here's one of the network specifications for libvirt:
    <interface type='direct'>
      <mac address='52:54:00:61:xxxx'/>
      <source dev='eth1' mode='vepa'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
   </interface>

The Windows drivers came from http://alt.fedoraproject.org/pub/alt/virtio-win/latest/images/virtio-win-0.1-100.iso in the 32 bit windows 7 directory of the iso (host is 64 bit, as is the emulated machine; Windows 7 is 32 bit). 