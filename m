From: Corentin CHARY <corentincj@iksaif.net>
Subject: Re: r8168, 2.6.17 et r8169.c
Date: Sat, 9 Sep 2006 14:51:14 +0200
Message-ID: <200609091451.14579.corentincj@iksaif.net>
References: <200609091201.03603.corentincj@iksaif.net> <20060909112414.GA2877@electric-eye.fr.zoreil.com>
Reply-To: corentincj@iksaif.net
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from iksaif.dns26.com ([84.246.226.15]:45504 "EHLO iksaif.net")
	by vger.kernel.org with ESMTP id S932133AbWIIMvG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Sep 2006 08:51:06 -0400
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
In-Reply-To: <20060909112414.GA2877@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 9 septembre 2006 13:24, vous avez =E9crit=A0:
> Corentin CHARY <corentincj@iksaif.net> :
> [...]
>
> > J'ai vu apr=E8s qu'il y'avais des patchs plus =E0 jour ici
> > http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.18-rc5/r8169/ , mai=
s pour
> > 2.6.18.
> >
> > Je me demande donc si il y'a un moyen de faire marcher le driver r8=
169.c
> > pour ma r8168 sur le kernel 2.6.17. Sinon, j'attendrais le 2.6.18 :=
).
>
> Vous appliquez les patchs pour 2.6.8-rc5 a la derniere version 2.6.18=
-rc
> disponible, vous modifiez la ligne qui comprend une directive 'reques=
t_irq'
> pour qu'elle soit identique a celle du pilote du noyau 2.6.17 et le p=
ilote
> obtenu devrait compiler avec votre noyau 2.6.17.
>
> Si le lien ne se negocie pas bien, forcez une autonegotiation avec
> l'utilitaire mii-tool (ne s'applique qu'au pilote apres bricolage).
>
> Dans tous les cas un 'lspci -vvx' de votre machine sera le bienvenu.
>
> En cas de probleme, il serait preferable de poursuivre la discussion
> en anglais en mettant la liste de diffusion 'netdev@vger.kernel.org'
> en copie.

Small summary (for the mailing list) :
--
I have a Asus Laptop A6JC, and a r8168 network card. r1000 driver from =
realtek=20
works, but I want to use r8169.c.
I first tried with=20
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.17-rc6/r8169/ patchs, b=
ut it=20
doesn't Work (eth0 is here, I can use ifconfig and route, but ping or d=
hcpcd=20
doesn't work)=20
--

Now I tried with http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.18-rc5=
/r8169/=20
I changed :
line 1751
- request_irq(dev->irq, rtl8169_interrupt, IRQF_SHARED, dev->name, dev)=
;
+ request_irq(dev->irq, rtl8169_interrupt, SA_SHIRQ, dev->name, dev);
line 2224
- u32 mss =3D skb_shinfo(skb)->gso_size;
+ u32 mss =3D skb_shinfo(skb)->tso_size;
to get it compile on 2.6.17

I can load the module, eth0 is here, I can play with ifconfig. But i ca=
n't=20
ping other machines on my network. dhcpd doesn't work too.

dmesg output :
r8169 Gigabit Ethernet driver 2.2LK loaded
ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:02:00.0 to 64
eth0: RTL8168b/8111b at 0xf0fe6000, 00:17:31:c1:8d:ee, IRQ 16
r8169: eth0: link down
r8169: eth0: link down
r8169: eth0: link up

lspci :
02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/81=
68B PCI=20
Express Gigabit Ethernet controller (rev 01)
        Subsystem: ASUSTeK Computer Inc. Unknown device 11f5
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- Par=
Err-=20
Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
-=20
<TAbort- <MAbort- >SERR- <PERR-
        Interrupt: pin A routed to IRQ 16
        Region 0: I/O ports at c800 [size=3D256]
        Region 2: Memory at fe0ff000 (64-bit, non-prefetchable) [size=3D=
4K]
        Expansion ROM at fe0e0000 [disabled] [size=3D64K]
        Capabilities: [40] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D375mA=20
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=3D0 DScale=3D0 PME-
        Capabilities: [48] Vital Product Data
        Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=3D=
0/1=20
Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [60] Express Endpoint IRQ 0
                Device: Supported: MaxPayload 1024 bytes, PhantFunc 0, =
ExtTag-
                Device: Latency L0s unlimited, L1 unlimited
                Device: AtnBtn+ AtnInd+ PwrInd+
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsuppor=
ted-
                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
                Link: Supported Speed 2.5Gb/s, Width x4, ASPM L0s L1, P=
ort 0
                Link: Latency L0s unlimited, L1 unlimited
                Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
                Link: Speed 2.5Gb/s, Width x4
        Capabilities: [84] Vendor Specific Information
00: ec 10 68 81 03 00 10 00 01 00 00 02 08 00 00 00
10: 01 c8 00 00 00 00 00 00 04 f0 0f fe 00 00 00 00
20: 00 00 00 00 00 00 00 00 02 01 00 00 43 10 f5 11
30: 00 00 0e fe 40 00 00 00 00 00 00 00 0b 01 00 00


I tried mii-tool (and mii-diag) but I get that :
SCIOCGMIIPHY on eth0 failed: Operation not supported

Thanks
--=20
CHARY 'Iksaif' Corentin
iksaif@gmail.com - corentincj@yahoo.fr
http://xf.iksaif.net
