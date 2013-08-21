From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH net] skge: dma_sync the whole receive buffer
Date: Wed, 21 Aug 2013 18:04:11 +0200
Message-ID: <5214E4FB.7010208@gmail.com>
References: <20130810104100.0ae20aa6@nehalam.linuxnetplumber.net> <20130810.132935.1257046025460198490.davem@davemloft.net> <20130810150207.37432299@nehalam.linuxnetplumber.net> <20130813.150955.1471100759610399160.davem@davemloft.net> <20130813180036.3e639789@nehalam.linuxnetplumber.net> <520B59D3.4020103@gmail.com> <20130814092022.494caf2b@nehalam.linuxnetplumber.net> <520BCC72.8040002@gmail.com> <20130815084117.2f48fc58@nehalam.linuxnetplumber.net> <52116B9C.8050003@gmail.com> <5212E249.2050203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:38956 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696Ab3HUQEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 12:04:16 -0400
Received: by mail-ea0-f175.google.com with SMTP id m14so375077eaj.6
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 09:04:15 -0700 (PDT)
In-Reply-To: <5212E249.2050203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.08.2013 05:28, poma wrote:
> On 19.08.2013 02:49, poma wrote:
>> On 15.08.2013 17:41, Stephen Hemminger wrote:
>>> On Wed, 14 Aug 2013 20:29:06 +0200
>>> poma <pomidorabelisima@gmail.com> wrote:
>>>
>>>> On 14.08.2013 18:20, Stephen Hemminger wrote:
>>>>> On Wed, 14 Aug 2013 12:20:03 +0200
>>>>> poma <pomidorabelisima@gmail.com> wrote:
>>>>>
>>>>>> On 14.08.2013 03:00, Stephen Hemminger wrote:
>>>>>>> On Tue, 13 Aug 2013 15:09:55 -0700 (PDT)
>>>>>>> David Miller <davem@davemloft.net> wrote:
>>>>>>>
>>>>>>>> From: Stephen Hemminger <stephen@networkplumber.org>
>>>>>>>> Date: Sat, 10 Aug 2013 15:02:07 -0700
>>>>>>>>
>>>>>>>>> The DMA sync should sync the whole receive buffer, not just
>>>>>>>>> part of it. Fixes log messages dma_sync_check.
>>>>>>>>>
>>>>>>>>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>>>>>>>>
>>>>>>>> Applied, but I really suspect that your "check DMA mapping err=
ors"
>>>>>>>> patch has added a serious regression.  A regression much worse=
 than
>>>>>>>> the bug you were trying to fix with that change.
>>>>>>>
>>>>>>> Argh. The problem is deeper than that. Device got broken somewh=
ere between
>>>>>>> 3.2 and 3.4. My old Dlink card works on 3.2 but gets DMA errors=
 on 3.4.
>>>>>>> The config's are different though so checking that as well.
>>>>>>>
>>>>>>
>>>>>> Can I help you with debugging?
>>>>>> DGE-530T is rather solid device.
>>>>>
>>>>> Don't think it is a hardware problem.
>>>>> The failure is when the board access the Receive ring PCI memory =
area.
>>>>> This region is allocated with pci_alloc_consistent and therefore =
should
>>>>> be available. Two possible issues are driver math issues, or hard=
ware
>>>>> problems with where the region is located. Some of these cards do=
n't
>>>>> really have full 64 bit PCI support.
>>>>>
>>>>> My board is:
>>>>> 05:01.0 Ethernet controller: D-Link System Inc Gigabit Ethernet A=
dapter (rev 11)
>>>>> 	Subsystem: D-Link System Inc DGE-530T Gigabit Ethernet Adapter
>>>>> 	Flags: bus master, 66MHz, medium devsel, latency 32, IRQ 18
>>>>> 	Memory at f7d20000 (32-bit, non-prefetchable) [size=3D16K]
>>>>> 	I/O ports at c000 [size=3D256]
>>>>> 	Expansion ROM at f7d00000 [disabled] [size=3D128K]
>>>>> 	Capabilities: [48] Power Management version 2
>>>>> 	Capabilities: [50] Vital Product Data
>>>>> 	Kernel driver in use: skge
>>>>>
>>>>>
>>>>> What is your config?
>>>>>
>>>>
>>>> 01:09.0 Ethernet controller: D-Link System Inc Gigabit Ethernet Ad=
apter
>>>> (rev 11)
>>>> 	Subsystem: D-Link System Inc DGE-530T Gigabit Ethernet Adapter
>>>> 	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 19
>>>> 	Memory at fbffc000 (32-bit, non-prefetchable) [size=3D16K]
>>>> 	I/O ports at b400 [size=3D256]
>>>> 	[virtual] Expansion ROM at ec000000 [disabled] [size=3D128K]
>>>> 	Capabilities: [48] Power Management version 2
>>>> 	Capabilities: [50] Vital Product Data
>>>> 	Kernel driver in use: skge
>>>>
>>>>
>>>> poma
>>>>
>>>
>>> In the course of debugging this, I moved the card to another slot
>>> and all the problems went away. I suspect either card insertion or =
more likely
>>> the crap consumer motherboards don't have full PCI support on some =
slots.
>>>
>>> There doesn't seem to be anyway to address this in software.
>>>
>>
>>
>> DGE-530T is further tested in the 3 available slots:
>> 01:06.0 Ethernet controller: D-Link System Inc Gigabit Ethernet Adap=
ter
>> (rev 11)
>> 01:07.0 Ethernet controller: D-Link System Inc Gigabit Ethernet Adap=
ter
>> (rev 11)
>> 01:08.0 Ethernet controller: D-Link System Inc Gigabit Ethernet Adap=
ter
>> (rev 11)
>> And the result is the same as in the slot:
>> 01:09.0 Ethernet controller: D-Link System Inc Gigabit Ethernet Adap=
ter
>> (rev 11)
>> warnings, oopses and kernel crashes.
>>
>> However DGE-528T(RTL8110s) on the same bus runs without errors:
>> 01:09.0 Ethernet controller: D-Link System Inc DGE-528T Gigabit Ethe=
rnet
>> Adapter (rev 10)
>> 	Subsystem: D-Link System Inc DGE-528T Gigabit Ethernet Adapter
>> 	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 19
>> 	I/O ports at cc00 [size=3D256]
>> 	Memory at fbfff000 (32-bit, non-prefetchable) [size=3D256]
>> 	[virtual] Expansion ROM at fbe00000 [disabled] [size=3D128K]
>> 	Capabilities: [dc] Power Management version 2
>> 	Kernel driver in use: r8169
>>
>> Besides comparing the behavior of these two cards, e.g. NFS upload, =
I
>> noticed an obvious difference in the data flow.
>> Via DGE-528T transmission is steady, while via DGE-530T the traffic =
is
>> at times interrupted and unstable.
>> So it seems that the "WARNING: at lib/dma-debug.c:937 check_unmap=85=
"
>> isn't just a fun.
>>
>=20
> In support of the validity of the device I made a test with the
> 2.6.32-358.14.1.el6.x86_64.debug kernel.
> And everything worked as it should.
>=20
> 01:08.0 Ethernet controller: D-Link System Inc Gigabit Ethernet Adapt=
er
> (rev 11)
> 	Subsystem: D-Link System Inc DGE-530T Gigabit Ethernet Adapter
> 	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 18
> 	Memory at fbff8000 (32-bit, non-prefetchable) [size=3D16K]
> 	I/O ports at cc00 [size=3D256]
> 	[virtual] Expansion ROM at fbe00000 [disabled] [size=3D128K]
> 	Capabilities: [48] Power Management version 2
> 	Capabilities: [50] Vital Product Data
> 	Kernel driver in use: skge
> 	Kernel modules: skge
>=20
> filename:
> /lib/modules/2.6.32-358.14.1.el6.x86_64.debug/kernel/drivers/net/skge=
=2Eko
> version:        1.13
> license:        GPL
> author:         Stephen Hemminger <shemminger@linux-foundation.org>
> description:    SysKonnect Gigabit Ethernet driver
> srcversion:     ADF6781C2E0D2D895F86279
> alias:          pci:v00001737d00001032sv*sd00000015bc*sc*i*
> alias:          pci:v00001737d00001064sv*sd*bc*sc*i*
> alias:          pci:v00001371d0000434Esv*sd*bc*sc*i*
> alias:          pci:v000011ABd00005005sv*sd*bc*sc*i*
> alias:          pci:v000011ABd00004320sv*sd*bc*sc*i*
> alias:          pci:v00001186d00004B01sv*sd*bc*sc*i*
> alias:          pci:v00001186d00004C00sv*sd*bc*sc*i*
> alias:          pci:v00001148d00004320sv*sd*bc*sc*i*
> alias:          pci:v00001148d00004300sv*sd*bc*sc*i*
> alias:          pci:v000010B7d000080EBsv*sd*bc*sc*i*
> alias:          pci:v000010B7d00001700sv*sd*bc*sc*i*
> depends:
> vermagic:       2.6.32-358.14.1.el6.x86_64.debug SMP mod_unload modve=
rsions
> parm:           debug:Debug level (0=3Dnone,...,16=3Dall) (int)
>=20
>=20
> Given all the tests and all written, something isn't right, at all.
> Should I quote Shakespeare. :)
>=20

Additionally, I have researched the history of the event and made a few
more tests.
The last kernel that worked flawlessly is from the 3.7.10 series.
I tested with the 3.7.10-400.fc19.x86_64.debug kernel.
The first kernel afterwards - the 3.8 series - introduced problems with
DMA-API, "=85 device driver failed to check map error".
An example that follows shows the skge module brokenness in its current
state.
The only thing that is produced is a timeout.
The same result was achieved with the 3.11.0-0.rc6.git1.1.fc20.i686 ker=
nel.

[CLIENT]

$ lspci -knn -d 1186:4c00
01:08.0 Ethernet controller [0200]: D-Link System Inc Gigabit Ethernet
Adapter [1186:4c00] (rev 11)
	Subsystem: D-Link System Inc DGE-530T Gigabit Ethernet Adapter [1186:4=
c00]
	Kernel driver in use: skge

$ modinfo skge
filename:
/lib/modules/3.11.0-0.rc6.git1.1.fc20.x86_64/kernel/drivers/net/etherne=
t/marvell/skge.ko
version:        1.14
license:        GPL
author:         Stephen Hemminger <shemminger@linux-foundation.org>
description:    SysKonnect Gigabit Ethernet driver
srcversion:     BF56B39CFC55B011E27DAB9
alias:          pci:v00001737d00001032sv*sd00000015bc*sc*i*
alias:          pci:v00001737d00001064sv*sd*bc*sc*i*
alias:          pci:v00001371d0000434Esv*sd*bc*sc*i*
alias:          pci:v000011ABd00005005sv*sd*bc*sc*i*
alias:          pci:v000011ABd00004320sv*sd*bc*sc*i*
alias:          pci:v00001186d00004302sv*sd*bc*sc*i*
alias:          pci:v00001186d00004C00sv*sd*bc*sc*i*
alias:          pci:v00001186d00004B01sv*sd*bc*sc*i*
alias:          pci:v00001148d00004320sv*sd*bc*sc*i*
alias:          pci:v00001148d00004300sv*sd*bc*sc*i*
alias:          pci:v000010B7d000080EBsv*sd*bc*sc*i*
alias:          pci:v000010B7d00001700sv*sd*bc*sc*i*
depends:
intree:         Y
vermagic:       3.11.0-0.rc6.git1.1.fc20.x86_64 SMP mod_unload
signer:         Fedora kernel signing key
sig_key:        B1:4E:0F:25:52:6B:EE:0B:8B:66:BA:D6:38:99:D2:21:5D:37:E=
1:C1
sig_hashalgo:   sha256
parm:           debug:Debug level (0=3Dnone,...,16=3Dall) (int)

$ time ssh -vvv <SERVER_IP>
OpenSSH_6.2p2, OpenSSL 1.0.1e-fips 11 Feb 2013
debug1: Reading configuration data $HOME/.ssh/config
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: /etc/ssh/ssh_config line 51: Applying options for *
debug2: ssh_connect: needpriv 0
debug1: Connecting to <SERVER_IP> [<SERVER_IP>] port 22.
debug1: Connection established.
debug1: identity file $HOME/.ssh/id_rsa type -1
debug1: identity file $HOME/.ssh/id_rsa-cert type -1
debug3: Incorrect RSA1 identifier
debug3: Could not load "$HOME/.ssh/id_dsa" as a RSA1 public key
debug1: identity file $HOME/.ssh/id_dsa type 2
debug1: identity file $HOME/.ssh/id_dsa-cert type -1
debug1: Enabling compatibility mode for protocol 2.0
debug1: Local version string SSH-2.0-OpenSSH_6.2
debug1: Remote protocol version 2.0, remote software version OpenSSH_6.=
2
debug1: match: OpenSSH_6.2 pat OpenSSH*
debug2: fd 3 setting O_NONBLOCK
debug3: load_hostkeys: loading entries for host "<SERVER_IP>" from file
"$HOME/.ssh/known_hosts"
debug3: load_hostkeys: found key type RSA in file $HOME/.ssh/known_host=
s:1
debug3: load_hostkeys: loaded 1 keys
debug3: order_hostkeyalgs: prefer hostkeyalgs:
ssh-rsa-cert-v01@openssh.com,ssh-rsa-cert-v00@openssh.com,ssh-rsa
debug1: SSH2_MSG_KEXINIT sent
Connection to <SERVER_IP> timed out while waiting to read

real	1m0.133s
user	0m0.006s
sys	0m0.036s

# tcptrack -i enp1s8 port 22
Client                Server                State        Idle A Speed

 <CLIENT_IP>:53602     <SERVER_IP>:22        ESTABLISHED  1m    0 B/s

[\CLIENT]
=2E
=2E
[SERVER]

/var/log/secure
<DATE> <SERVER> sshd[25248]: Connection closed by <CLIENT_IP> [preauth]

[\SERVER]


Signor Greg you are supposed to be very resourceful guy, especially in
matters concerning the hardware, so please if you can set aside your
valuable time and help us finally resolve this issue.


poma


A complete thread:
http://www.spinics.net/lists/netdev/msg245381.html
