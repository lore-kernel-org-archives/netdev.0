From: Jesse Gross <jesse@nicira.com>
Subject: Re: [patch net-next-2.6 18/47] igbvf: do vlan cleanup
Date: Wed, 20 Jul 2011 10:26:14 -0700
Message-ID: <CAEP_g=9D5CEUG7AVxoyW6Q0NUEaQ+vE3g+SPdU677Y+s65JRiA@mail.gmail.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com> <1311173689-17419-19-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com, mirqus@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	peter.p.waskiewicz.jr@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, e1000-devel@lists.sourceforge.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:43027 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab1GTR0e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 13:26:34 -0400
Received: by yxi11 with SMTP id 11so216070yxi.19
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 10:26:34 -0700 (PDT)
In-Reply-To: <1311173689-17419-19-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 7:54 AM, Jiri Pirko <jpirko@redhat.com> wrote:
> @@ -1170,19 +1170,28 @@ static void igbvf_set_rlpml(struct igbvf_adap=
ter *adapter)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int max_frame_size =3D adapter->max_frame_=
size;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct e1000_hw *hw =3D &adapter->hw;
>
> - =C2=A0 =C2=A0 =C2=A0 if (adapter->vlgrp)
> + =C2=A0 =C2=A0 =C2=A0 if (adapter->netdev->features & NETIF_F_HW_VLA=
N_RX)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0max_frame_size=
 +=3D VLAN_TAG_SIZE;

This is unconditionally true, right?  NETIF_F_HW_VLAN_RX never gets
toggled here.  In any case, I think we should be able to handle vlan
tagged packets even if stripping isn't enabled.

The Intel guys have expressed some concerns in the past about the MTU
in relation to the igb driver (the PF version) with vlan tags.  I'm
not quite sure what about this NIC is different from others in the
handling of MTU and vlans but here's one such thread:
http://patchwork.ozlabs.org/patch/82675/
