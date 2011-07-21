From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 37/47] igb: do vlan cleanup
Date: Thu, 21 Jul 2011 08:57:22 +0200
Message-ID: <20110721065721.GA2199@minipsycho>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
 <1311173689-17419-38-git-send-email-jpirko@redhat.com>
 <CAEP_g=_0Ej09+KYbvEJz1+joYtms+S_67XSVVPMoG_hfJnmrBQ@mail.gmail.com>
 <20110720191045.GD2688@minipsycho.redhat.com>
 <CAEP_g=9j3=s74_VQ6RQxVRGOOs-mVR94s31ETXJ1S5P7aQV4iQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com, mirqus@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	peter.p.waskiewicz.jr@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, e1000-devel@lists.sourceforge.net
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44986 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003Ab1GUG5l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 02:57:41 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=9j3=s74_VQ6RQxVRGOOs-mVR94s31ETXJ1S5P7aQV4iQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 21, 2011 at 01:58:10AM CEST, jesse@nicira.com wrote:
>On Wed, Jul 20, 2011 at 12:10 PM, Jiri Pirko <jpirko@redhat.com> wrote=
:
>> Wed, Jul 20, 2011 at 07:35:33PM CEST, jesse@nicira.com wrote:
>>>On Wed, Jul 20, 2011 at 7:54 AM, Jiri Pirko <jpirko@redhat.com> wrot=
e:
>>>> @@ -2943,7 +2944,7 @@ static void igb_rlpml_set(struct igb_adapter=
 *adapter)
>>>> =A0 =A0 =A0 =A0struct e1000_hw *hw =3D &adapter->hw;
>>>> =A0 =A0 =A0 =A0u16 pf_id =3D adapter->vfs_allocated_count;
>>>>
>>>> - =A0 =A0 =A0 if (adapter->vlgrp)
>>>> + =A0 =A0 =A0 if (igb_vlan_used(adapter))
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0max_frame_size +=3D VLAN_TAG_SIZE;
>>>
>>>There are similar issues here as with the VF driver. =A0I think you'=
re
>>>also confusing vlan acceleration with vlan filtering. =A0If no vlan
>>>filters are in use but the card is in promiscuous mode, the buffer
>>>will be undersized and we lose tagged packets.
>>
>> I'm certainly not confusing vlan accel and filtering. Here is the
>> intension is the behaviour remains intact as well. I believe it's tr=
ue.
>
>I believe the underlying issue for all three of these threads is the
>same, so I'll just respond to them all here.
>
>I agree that this doesn't change the behavior of the driver but I
>don't think that should be the goal.  When I originally designed this
>new vlan model my intention was to eliminate a whole class of driver
>bugs that I was repeatedly hitting in various forms.  In the example
>above, if you run tcpdump on this device without configuring a vlan
>group on it then you will see that MTU sized packets are missing
>because the receive buffer was undersized.
>
>The common theme for these problems is that they all occur in
>situations where vlans are not configured on the device and the driver
>does something different as a result of this.  The solution was to
>prevent drivers from changing their behavior in such situations by
>completely removing the concept of a vlan group from them and letting
>the networking core tell them when to make the changes instead of
>doing it implicitly.  That's why I don't see the fact that this change
>essentially emulates the knowledge of configuring a group to be a
>plus.  By the way, plenty of your other patches change the behavior of
>the drivers - on any of the NICs that always enable stripping, try
>running tcpdump on the interface without configuring a vlan group.
>Before the change you will see that tags have disappeared and
>afterwards the tags are intact.  So I think that changing the behavior
>of drivers in this regard is a positive thing.
>
>As an aside, thank you for taking the time to work on all of these
>drivers.  The only reason why I'm complaining about these few drivers
>is because I'd like to close the door on this class of problems, which
>is finally in reach thanks to your work.


Okay now it's clear to me. I tried to stay with the code as much simila=
r
as unpatched. But I see your arguments. I will review and repost
patches which are enabling/disabling vlan accel on add_vid/kill_vid and
convert it to set_features.

Thanks. Jesse.

Jirka
