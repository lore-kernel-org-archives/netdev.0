From: Christian Hesse <mail@eworm.de>
Subject: sky2, vlan and nat/masquerading
Date: Wed, 9 Mar 2011 18:15:22 +0100
Message-ID: <20110309181522.61ca1cc7@leda.vpn.lugor.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/sQ/QWla6_ks8jUbO9HM1LFc"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([80.190.48.209]:41791 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367Ab1CIRZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 12:25:47 -0500
Received: from mx.mylinuxtime.de (unknown [127.0.0.1])
	by mx.mylinuxtime.de (Postfix) with ESMTP id D3C89980714
	for <netdev@vger.kernel.org>; Wed,  9 Mar 2011 18:15:23 +0100 (CET)
Received: from leda.vpn.lugor.de (unknown [IPv6:2a01:138:b005:1:e056:e1ff:feb5:3ffb])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by mx.mylinuxtime.de (Postfix) with ESMTPSA id 9BABD9803C1
	for <netdev@vger.kernel.org>; Wed,  9 Mar 2011 18:15:23 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/sQ/QWla6_ks8jUbO9HM1LFc
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello everybody,

I have a Samsung NF310, running kernel 2.6.37.3 with a patch to make my
ethernet controller work for vlans. It was discussed with the subject "sky2:
convert to new VLAN model (v0.2)" and made it to to kernel tree with commit
86aa77854f47ab6f5f9c687507af1f57d2b89004.
However it does not work properly, here are the details:

* Switch with one trunk port and several port in corresponding vlan ports
* Host connected to one of the vlan ports
* Samsung Netbook (see above) connected to the trunk port.

I get an IP address 192.168.x.x/24 via DHCP on interface connected to vlan 1.
The interface connected to vlan 2 has 172.16.0.1/24 and serves addresses via
DHCP. The system is set up to masquerade from 172.16.0.1/24.

I can access my netbook from the host in vlan 2, however I can not access
anything behind. The packets contain a broken vlan tag and the host does not
recognize them.
I've attached a tcpdump log. Please take a look at the icmp echo request and
reply packets, especially the last one.

I've tested with an usb-ethernet-adapter and everything works fine, so my
setup is ok.
-- 
Regards,
Chris
--MP_/sQ/QWla6_ks8jUbO9HM1LFc
Content-Type: application/octet-stream; name=tcpdump.log
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=tcpdump.log

1MOyoQIABAAAAAAAAAAAAGAAAAABAAAA/EF3TX30AwBaAAAAlwAAAP///////wAkVNg6YQgARQAA
iQAAQABAEeFDrBAAAawQAP9EXERcAHWPPHsiaG9zdF9pbnQiOiA0MTEyMTg1NiwgInZlcnNpb24i
OiBbMSwgOF0sICJkaXNwbP9Bd01MOgQAWgAAAGIAAAAAJFTYOmEAJi33oKkIAEUAAFQAAEAAQAFp
2KwQABXAqGQDCABbiQmpAAH/QXdNLToEAAgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyAhIiMkJSYn
KCkqKywtLi//QXdNnUwEAFoAAABmAAAAACYt96CpACRU2DphgQAAAAgARQAAVHZpAAA9ATZvwKhk
A6wQABUAAGOJCakAAf9Bd00tOgQACAkKCwwNDg8QERITFBUWFxgZGhscHR4fICEiIyQlJicoKSor
BEJ3TSM/BAAqAAAAKgAAAAAkVNg6YQAmLfegqQgGAAEIAAYEAAEAJi33oKmsEAAVAAAAAAAArBAA
AQRCd01BQQQAPAAAADwAAAAAJi33oKkAJFTYOmEIBgABCAAGBAACACRU2DphrBAAAQAmLfegqawQ
ABUAAAAAAAAAAAAAAAAAAPwpq9MMQndNZ04HAFoAAABiAAAAACRU2DphACYt96CpCABFAABUAABA
AEAB4nKsEAAVrBAAAQgALnQJqgABDEJ3TUpOBwAICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIj
JCUmJygpKissLS4vDEJ3TS1RBwBaAAAAYgAAAAAmLfegqQAkVNg6YQgARQAAVL50AABAAWP+rBAA
AawQABUAADZ0CaoAAQxCd01KTgcACAkKCwwNDg8QERITFBUWFxgZGhscHR4fICEiIyQlJicoKSor
LC0uLw==

--MP_/sQ/QWla6_ks8jUbO9HM1LFc--
