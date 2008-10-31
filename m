From: Krzysztof Oledzki <ole@ans.pl>
Subject: e1000 kills IPMI on 82541GI (Dell PE1425SC) + small 2.6.27
 regression
Date: Fri, 31 Oct 2008 11:04:13 +0100 (CET)
Message-ID: <alpine.LNX.1.10.0810311012160.12764@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1144830174-288609127-1225447454=:12764"
Cc: auke-jan.h.kok@intel.com, jesse.brandeburg@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:50917 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbYJaKGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 06:06:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1144830174-288609127-1225447454=:12764
Content-Type: TEXT/PLAIN; format=flowed; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT

Hello,

I have started implementing IPMI on my servers and there is some 
inconvenience with e1000+82541GI (Dell PE1425SC).

With older kernels IPMI works if there are no vlans attached to primary 
interface. Adding vlans breaks it as e1000 driver enables VLAN filter and 
it somehow interferences with IPMI.

(no vlans):
# ethtool -d eth0|grep -i vlan
       VLAN mode:                         disabled
       VLAN filter:                       disabled

(vlans):
# ethtool -d eth0|grep -i vlan
       VLAN mode:                         enabled
       VLAN filter:                       enabled

However, I found that using a workaround by adding the IPMI vlan to the OS 
restores the functionality. Very ugly but works.

So, it is OK with no-vlan-enabled hosts and with vlan-enabled with the 
above workaround, but still - it is a ugly workaround: IPMI is 
non-functional until OS *properly* initializes network configuration, 
which may never happen.

Everything becomes much more complicated with more recent kernels (2.6.27 
for example), where vlan filter is now enabled unconditionally and I have 
to add the dummy IPMI vlan also on no-vlan-enabled hosts to make it 
working. That makes it really confusing.

So, is it possible to fix this? For example to change the driver to read 
IPMI vlan id and add it to vlan filter regardless of current OS 
configuration? Or maybe it is possible to prevent IPMI from interferencing 
with the current driver's state?

Best regards,

 				Krzysztof Olêdzki
---1144830174-288609127-1225447454=:12764--
