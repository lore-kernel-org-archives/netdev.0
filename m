From: Oliver Francke <Oliver.Francke@filoo.de>
Subject: Re: Crash in skb_segment / KVM GSO GRE IPV6
Date: Thu, 26 Nov 2015 16:40:00 +0100
Message-ID: <565727D0.9040303@filoo.de>
References: <20151114095326.GC3958@pax.zz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Florian Lohoff <f@zz.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-1.de-punkt.de ([93.190.64.237]:54941 "EHLO
	mail-1.de-punkt.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbbKZPrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 10:47:07 -0500
In-Reply-To: <20151114095326.GC3958@pax.zz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

well, I think this is a serious bug, as I can crash a complete linux
host running hundreds of VMs from within a QEMU-guest only.
All I can add here is a test-setup where I can try out possible fixes
without disturbing others.
The only things that helps out ATM is switch all eth-offloading off, bu=
t
that cannot be a long-term solution.

Please help and let's get this fixed,

Oliver.

On 11/14/2015 10:53 AM, Florian Lohoff wrote:
>=20
> Hi,
>=20
> we experienced a reproducible crash on a KVM/qemu Host running
> Kernel 4.3.0 in skb_segment. (Setup is kvm guest, openvswitch 1.9 up =
to
> 2.something, host on 4.3.0). User in the guest kvm with virtio report=
edly tried
> to set up an v4 GRE tunnel with IPv6 Addresses and as soon as he star=
ted a simple
> wget the host crashed.
>=20
> I couldnt catch the full backtrace on the Host (IPMI redirect)=20
> here is what i typed from the video:
>=20
>         NULL pointer dereference at 00000000084
>=20
>         IP skb_segment+0x487/0x970
>=20
>         RIP skb_segment+0x487/0x970
>=20
>         ? __enqueue_entity
>         tcp_gso_segment+0x11d/0x4a0
>         ? debug_smp_processor_id
>         tcp6_gso_segment
>         ipv6_gso_segment
>         ? default_wake_function
>         skb_mac_gso_segment
>         gre_gso_segment
>         ? __wake_up_sync_key
>         inet_gso_segment
>=20
> Using gdb on skbuff.o i find this:
>=20
> 3120                            if (i >=3D nfrags) {
>    0x0000000000005492 <+1154>:  cmp    %r15d,%r11d
>    0x0000000000005495 <+1157>:  jg     0x54d5 <skb_segment+1221>
>=20
> 3121                                    BUG_ON(skb_headlen(list_skb))=
;
>    0x0000000000005497 <+1159>:  mov    0x84(%r13),%eax
>    0x000000000000549e <+1166>:  cmp    %eax,0x80(%r13)
>    0x00000000000054a5 <+1173>:  jne    0x5962 <skb_segment+2386>
>    0x0000000000005962 <+2386>:  ud2
>=20
> Where 0x84 is skb->data_len - So skb_headlen(list_skb) hits
> an NULL list_skb.
>=20
> Flo
>=20


--=20

Oliver Francke

filoo GmbH
Moltkestra=DFe 25a
33330 G=FCtersloh
HRB4355 AG G=FCtersloh

Gesch=E4ftsf=FChrer: J.Rehp=F6hler | C.Kunz

=46olgen Sie uns auf Twitter: http://twitter.com/filoogmbh
