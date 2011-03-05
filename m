From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 6/8] bonding: move processing of recv handlers
 into handle_frame()
Date: Sat, 05 Mar 2011 15:50:28 +0100
Message-ID: <4D724DB4.9020207@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-7-git-send-email-jpirko@redhat.com> <4D7249BA.8030401@gmail.com> <20110305144314.GC8573@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48823 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab1CEOuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 09:50:32 -0500
Received: by wyg36 with SMTP id 36so3015618wyg.19
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 06:50:31 -0800 (PST)
In-Reply-To: <20110305144314.GC8573@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/03/2011 15:43, Jiri Pirko a =E9crit :
> Sat, Mar 05, 2011 at 03:33:30PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>> Le 05/03/2011 11:29, Jiri Pirko a =E9crit :
>>> Since now when bonding uses rx_handler, all traffic going into bond
>>> device goes thru bond_handle_frame. So there's no need to go back i=
nto
>>> bonding code later via ptype handlers. This patch converts
>>> original ptype handlers into "bonding receive probes". These functi=
ons
>>> are called from bond_handle_frame and they are registered per-mode.
>>
>> Does this still support having the arp_ip_target on a vlan?
>>
>> (eth0 ->  bond0 ->  bond0.100, with arp_ip_target only reachable thr=
ough bond0.100).
>
> This case is still covered with vlan_on_bond_hook
> eth0->
> 	bond_handle_frame
> bond0->
> 	vlan_hwaccel_do_receive
> bond0.5->
> 	vlan_on_bond_hook ->  reinject into bond0
> 				->  bond_handle_frame (here it is processed)

Sound good to me.

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
