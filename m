From: Ben Greear <greearb@candelatech.com>
Subject: VLAN regression caused by: e1000: do vlan cleanup (799d531).
Date: Mon, 12 Mar 2012 11:17:51 -0700
Message-ID: <4F5E3DCF.6010307@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020002060103010206060800"
Cc: netdev <netdev@vger.kernel.org>
To: e1000-devel list <e1000-devel@lists.sourceforge.net>,
	Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39631 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752997Ab2CLSSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 14:18:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020002060103010206060800
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This commit breaks 802.1Q VLANs on my e1000 NIC, and it remains broken in top-of-tree
(as of 2 days ago, at least).

commit 5622e4044a916de1af84bfcc4d437ce0c799d531
Author: Jiri Pirko <jpirko@redhat.com>
Date:   Thu Jul 21 03:26:31 2011 +0000

     e1000: do vlan cleanup

     - unify vlan and nonvlan rx path
     - kill adapter->vlgrp and e1000_vlan_rx_register
     - allow to turn on/off rx/tx vlan accel via ethtool (set_features)

     Signed-off-by: Jiri Pirko <jpirko@redhat.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>


My OS is RH 8, 32-bit.

My e1000 hardware is:

05:01.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
	Subsystem: Intel Corporation PRO/1000 MT Dual Port Server Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 52 (63750ns min), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 24
	Region 0: Memory at d8100000 (64-bit, non-prefetchable) [size=128K]
	Region 4: I/O ports at 3000 [size=64]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [e4] PCI-X non-bridge device
		Command: DPERE- ERO+ RBC=512 OST=1
		Status: Dev=05:01.0 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
	Capabilities: [f0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Kernel driver in use: e1000
	Kernel modules: e1000

05:01.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
	Subsystem: Intel Corporation PRO/1000 MT Dual Port Server Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 52 (63750ns min), Cache Line Size: 32 bytes
	Interrupt: pin B routed to IRQ 25
	Region 0: Memory at d8120000 (64-bit, non-prefetchable) [size=128K]
	Region 4: I/O ports at 3040 [size=64]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [e4] PCI-X non-bridge device
		Command: DPERE- ERO+ RBC=512 OST=1
		Status: Dev=05:01.1 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
	Capabilities: [f0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Kernel driver in use: e1000
	Kernel modules: e1000


I'm attaching ethregs output from good and bad kernels, in case that helps.

The symptom is that pkts show up as 'ISL' instead of Ethernet frames.  I'm
including a capture of that as well.  I am sending UDP pkts from one NIC to the other,
on vlan 8, though because ARP fails, no UDP is ever sent.  The sniff shows rcvd pkts
as looking funky, but it could be they are transmitted badly once they hit the NIC,
so I don't know if it's actually rx or tx (or both) logic that is busted at this point.

I'm using routing rules to make send-to-self work, but the kernel is un-patched.

Please let me know if you need additional info.  I'll be happy to test patches,
I have a good setup to reproduce this easily.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------020002060103010206060800
Content-Type: application/x-gzip;
 name="ethregs-e1000-bad-vlans.txt.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="ethregs-e1000-bad-vlans.txt.gz"

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
y/Bf7k/v1mNYPJH3t64XWobdWLx8y/DtFenne/Us8ku39JZbYvybtRS70FLsA0+2jMeWR6bl
uNlbjj+1pbjowvX58CXvf205vrm5f/eW/IUFjkVRziu/On2Zapkt9+vr7q8P3Ouv/OYkt0zz
Lc/eyy3PC1/8PDymroDt/ZWrH6Ylumyaz+CLkQu5JdoWbEu0WY9v40rL7Hb8hvDSD0MDx0+4
W2+Qpm7346frnxwfXY2OX+ZKy/bp6pa5Pwd+/fD1e/pfdRxcaOl2O+dauiPnWrphvcI/6Yud
G9cAf6mW7sDlz+entnSXVWHM/Atauq9O10Wal+t/+HROXr+Drf36C7sfwo3rxqoI6+Xr96xc
v2fl+g3Hj3/l6fGfrukLHMd3e3369uGMr5Dj9Vd+JfKzsv6srv8b+QAhfo9f4Pn7e63wvwqf
T6Flf/v8nN6kNthjPdvSbw6eW/plnlv6FZ5b+mWeW/plnlv6ZZ5b+mWeW/plnlv6ZZ5b+mWe
W/plnlv6RZ5b+nNLv8xzS7/M/90t/X4ovds519K/nNVJaukvYL3M0y39T9fLPN3S/3S9zLmW
/mO9zJMt/c/Wyzzd0v90vcxzS39u6cfc7z9cS3/496GVCy39RW7pzy39uaU/FQBinlv6ZZ5b
+mWeW/plnlv6ZZ5b+mWeW/pFnlv6FZ5b+mWeW/oVnlv6ZZ5b+mX++23pP/1NXJ9u+S+K3tqt
f0lr+V/XW9KiF+j6lbCnx8db2gF9rF85bSB9enyp/6TAjW4cbD9dXry9TvZ317F/6u3j9d13
Qv/cxq3CncJLnr+5uj4/0P795Y5nqrZe+DePiQbxYv1G3aIsLy8ev/nuzTffPf7n87P0xN+N
kB9FLuVvN3J+tHEpP7uR86ONC/nRxoX8aONCfrRxIT/auJAfBT/880Pg/PND4PzzQ+D880Pg
/PND4PzzQ+D880Pgwr8/3Mj5UeD880O4fhR/Qn4UuOJPyI8CV/wJ+VHgij/p329u5PwocMWf
kB8FrvgT8qPAFX9CfhS44k/IjwJX/An5UeCKPyE/ClzxJ+RHgSv+hPwocMWfkB8FrvgT8qPA
FX9CfhS44k/IjwJX/An5UeCKPyE/ClzxJ+RHgSv+hPwocMWfkB8FrvgT8qPAFX9CfhS44k/I
jwJX/An5UeCKPyE/ClzxJ+RHgSv+hPwocMWfkB8FrvgT8qPAFX9CfhS44k/IjwJX/An5UeCK
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
JgEA
--------------020002060103010206060800
Content-Type: application/x-gzip;
 name="ethregs-e1000-good-vlans.txt.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="ethregs-e1000-good-vlans.txt.gz"

H4sICHQ6Xk8AA2V0aHJlZ3MtZTEwMDAtZ29vZC12bGFucy50eHQA7Z1Nb+RGkobP0q/o48xl
wczkR9I3tVpqCyP1aKRytxeLgcHPXQNe22j0Xue3L8lkBqWIjAhDHq3tndTc5lGWig9ZTMbb
4Yqi+qow/2be/MkXvv7KFE375/ObH79MP7y5/Onzzz997r58/9OPb7ytyvr92zfvv//Prv/+
y5urL/81ff5x+rL80o9fPv/0ww/T5/OzD91/T2/Iz8fuh/+Zzs/+sfxQuP6//zg/uzw93FJY
eTcUtmzPzx5PF6dvHjEvlp++98352dXVJV2+8cKZYuUP7yifl5/1V8Lf/+7q21NifTEs/O7d
TeIPGG+7xq/rry8vEu9/WWsXbDb+NfP+TFh/onjjfjkt52cfr1i+rb85PXDHXwxu4ZdEHvBt
/R3P23HlrN+NP1yeksdflMvx2+34Th+T69dzcH52+vbyE/P6plve30OaD/H9n9J/3xRuLuZu
4Tf371OvXxe2WP1e3HB+w+vfXr1L/IWiKWrv1uO7f3uRXG/WC3A7vw+JN7i4Kbph2Dm9QIrA
l/f38O5t4gJzrt0UBJ5eX+z89upDkpudJy7Pfb2tVs77sW7jiQvwyd//Nukv/PmVX7yjl0dc
vx7/48M9/QAfr3/69t3dBblEd7x8/k7vrpnPnxn6YuOJA3zGv6afkOfrFX5PP0FP3j9zfv1g
gEvn96Sc35Nwfqd25fz53fiNfH5O6fNr4vk9CefXrvzx/o6+g211Ga6fy8dv7pLr7crvThf/
UfydeX87Nwq3CncKLxVeKbxWeKNwr/BW80MEIk4EIk4EIk4EIk4EIk4EIk4EIk4EIk4EIk4E
outH8WcVf1bxZxV/VvFnFX9W8WcVf1bxZxV/TvHnFH9O8ecUf07x5xR/TvHnFH9O8ecUf6Xi
r1T8lYq/UvFXKv5KxV+p+CsVf6Xir1T8VYq/SvFXKf4qxV+l+KsUf5Xir1L8VYq/SvFXK/5q
xV+t+KsVf7Xir1b81Yq/WvFXK/5qxV+j+GsUf43ir1H8NYq/RvHXKP4axV+j+GsUf17x5xV/
XvHnFX9e8ecVf17x5xV/XvHnFX+t4q9V/LWKv1bx1yr+WsVfq/hrFX+t4q9V/C3Fyt9ljgVi
jgVijgVijgVijgVijgVijgVijgVijgUiTgoQzBV/pADBXPFHChDMFX+kAMFc8UcKEMwVf6QA
wVzxRwoQzBV/pADBXPFHChDMeX8PF7ep+r+fxmnnXyf4mr9NrR/C+nQ+ME1xPeXr+qKNfz+V
H1TrnzdhPeXbehPXp/KFmB+v6ylf11tYn84f3PIT1lP+/O8n8ol+no/1lD/3l8ovnq6n/Lk/
Kd9Y18v8Vsw/1vUyvxXzkXW9zG/F/GS7fkR+K+Yr23qR34r5y7Ze5LdiPrOtF/mtmN9s60V+
m8h35v1nX5/a/13gH69TAWARrm+zc8HfxgU/GxeOf+PC8W1ceH7ZuPD8snHh+WXjwvPLxoXn
l+CH3z8C5/ePwPn9I3B+/wic3z8C5/ePwPn9I3B+/wic338D5/ffcP0o/oT9N3DFn7D/Bq74
E/bfwBV/wv4buOKPBICIkwAQc8UfCQAxV/yRABBzxR8JADFX/JEAEHPFHwkAMVf8kQAQc8Uf
CQAxV/yRABBzxR8JADFX/JEAEHPFHwkAMVf8kQAQc8UfCQAxV/yRABBzxR8JADFX/JEAEHPF
HwkAMVf8kQAQc8UfCQAxV/yRABBzxR8JADFX/JEAEHPFHwkAMVf8kQAQc8UfCQAxV/yRABBz
xR8JADFX/JEAEHPFHwkAMVf8kQAQc8UfCQAxV/yRABBzxR8JADFX/JEAEHPFHwkACTcKtwp3
Ci8VXim8VnijcK/wVua4ACFc8YcLEMIVf7gAIVzxhwsQwhV/uAAhXPGHCxDCFX+4ACFc8YcL
EMIVf7gAIZz19+kbvj8x8OvELzzlcn/k3cWHxHoX+g/t+dnN/QXfH7W9/n2iP3Eq7Fj3hTs/
u76+PTH5xbZ+40J+sXEhv9g4n1+cnxdbF3Dx++wCnotf0AXsXrULeNiuArYL2OUu4NwF/Jt1
Afu5297fa3YBG6UL2Pyxu4DHphC7gCPnuoBhvcJf0gVc9mYG/lpdwIXSBVzkLuDcBZz6RwDM
cxewzHMXsMhzF7DCcxewzHMXsMxzF7DMcxewzHMXsMxzF7DMcxewwnMXsMxzF7DIcxcw+vlF
XcD+V3YB+/j3/0W7gP2v7AIGf7kLWFmfu4Dp+twFfPDcBazw3AUs89wFLPPcBSzz3AUs89wF
LPPcBSzz3AUs8twFrPDcBSzz3AWs8NwFLPPcBSzz3AX87Kd2th+btb/qt+8CLr8qiiffBdzW
yS7g5Zfd1aO9vfggdQK/+dPlTz//PH3+8z+/JbgszFDa0rAtwbbwRePLrSU40fK7Hq6bjZdb
gm3NtQSbtd92+2Lg69t0y+f649dLhmsZNk27nfJXbhn+y93Dh/UYFk/k/a3rhZZhNxav3zJ8
c0H6+d48i/zSLb3llhj/Zi3FLrQU+8CTLeOx5ZFpOW72luOXthQXXbg+79/y/teW46uruw/v
yV9Y4FgU5bzyi4e3qZbZMrRUXt/+9Z57/ZVfPcgt03zLs/dyy/PCFz/3j6krYHt/5eqHaYku
66nc/v5rtkQHzh//XMgt0bZgW6LNenwbV1pmt+M3hJd+GBo4fsLdeoM0dbsfP13/5PjoanT8
Mldath8ubpj7c+CX9998pP9Vx8GFlm63c66lO3KupRvWK/xFLd3z0AJ/tZbuQmnpLl7e0l1W
hTHzL2jpvni4LNK8XP/Dp1Py+h1s7ddf2P0Qblw3VkVYL1+/J+X6PSnXbzh+/CtPj//hkr7A
cXw3lw/f3p/wFXK8/sovRH5S1p/U9X8jHyDE7/ALPH9/7xT+V+HzKbTsb5+fh+vUBnusZ1v6
zcFzS7/Mc0u/wnNLv8xzS7/Mc0u/zHNLv8xzS7/Mc0u/zHNLv8xzS7/Mc0u/yHNLf27pl3lu
6Zf5P7ul3w+ldzvnWvqXszpJLf0FrJd5uqX/6XqZp1v6n66XOdfSf6yXebKl/9l6madb+p+u
l3lu6c8t/Zj7/Ydr6Q//PrRyoaW/yC39uaU/t/SnAkDMc0u/zHNLv8xzS7/Mc0u/zHNLv8xz
S7/Ic0u/wnNLv8xzS7/Cc0u/zHNLv8z/uC39D38T16db/ouit3brX9Ja/tf1lrToBToVa3/k
4w3tgD7Wr5w2kD49vtR/UuBGNw62n87P3l8m+7vr2D/1/vHy9juhf27jVuFO4SXPry8uT/e0
f3+545mqrRf+6THRIL4sNb4oy/Ozx0/fXX/67vHfn5+lJ/6uhPwocil/u5Lzo41L+dmVnB9t
XMiPNi7kRxsX8qONC/nRxoX8KPjhnx8C558fAuefHwLnnx8C558fAuefHwLnnx8CF/794UrO
jwLnnx/C9aP4E/KjwBV/Qn4UuOJPyI8CV/xJ/35zJedHgSv+hPwocMWfkB8FrvgT8qPAFX9C
fhS44k/IjwJX/An5UeCKPyE/ClzxJ+RHgSv+hPwocMWfkB8FrvgT8qPAFX9CfhS44k/IjwJX
/An5UeCKPyE/ClzxJ+RHgSv+hPwocMWfkB8FrvgT8qPAFX9CfhS44k/IjwJX/An5UeCKPyE/
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
--------------020002060103010206060800
Content-Type: application/x-pcap;
 name="e1000-bad-vlans.pcap"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="e1000-bad-vlans.pcap"

1MOyoQIABAAAAAAAAAAAAP//AAABAAAAYataT+6cCwAqAAAAKgAAAP///////wDuAAAACAgG
AAEIAAYEAAEA7gAAAAgUAQEUAAAAAAAAFAEBFWGrWk8+nQsASAAAAEgAAAABAAwAAAAA4O0L
jOkAOqqqAwDg7QAQAAAAAP///////wDuAAAACQgGAAEIAAYEAAEA7gAAAAkUAQEVAAAAAAAA
FAEBFOcQoHQ=
--------------020002060103010206060800--
