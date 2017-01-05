From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [net-next PATCH 5/6] i40e: Add TX and RX support in switchdev
 mode.
Date: Thu, 05 Jan 2017 14:32:54 -0800
Message-ID: <586EC996.9080205@intel.com>
References: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com> <1483078863-22026-6-git-send-email-sridhar.samudrala@intel.com> <CAJ3xEMgDAUSE2gVD3dU4UuXFb7k_W-9QgHpg-0c7b5kxRC2=FQ@mail.gmail.com> <586693A6.5090105@intel.com> <CAJ3xEMjGuKKge+_hqZPOg2fp3f50TdxGtbKFXwnCZ70rPxmuyw@mail.gmail.com> <586D7B4E.2010308@intel.com> <CAJ3xEMgAaXNbvaP0=GcuTsVOOGwPHuSMQf-SeLKpxB8WrbEvng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        jakub.kicinski@netronome.com, intel-wired-lan@lists.osuosl.org,
        Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59210 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751091AbdAEWc4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 17:32:56 -0500
In-Reply-To: <CAJ3xEMgAaXNbvaP0=GcuTsVOOGwPHuSMQf-SeLKpxB8WrbEvng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 1/5/2017 3:50 AM, Or Gerlitz wrote:
> On Thu, Jan 5, 2017 at 12:46 AM, Samudrala, Sridhar
> <sridhar.samudrala@intel.com> wrote:
>>
>> On 1/3/2017 3:03 PM, Or Gerlitz wrote:
>>> On Fri, Dec 30, 2016 at 7:04 PM, Samudrala, Sridhar
>>> <sridhar.samudrala@intel.com> wrote:
>>>> On 12/30/2016 7:31 AM, Or Gerlitz wrote:
>>>>> Are you exposing switchdev ops for the representators? didn't see that
>>>>> or maybe it's in the 4th patch which didn't make it to the list?
>>>> Not at this time. In the future patches when we offload fdb/vlan
>>>> functionality, we could use switchdev ops.
>>> but wait, this is the switchdev mode... even before doing any
>>> offloading, you want (need) your representor netdevices to have the
>>> same HW ID marking they are all ports of the same ASIC, this you can
>>> do with the switchdev parent ID attribute.
>> OK. I will add switchdev_port_attr_get() with PORT_PARENT_ID support in v3.
> Good, I made this comment, b/c we want to create a well defined user-experience
> to be taken into account also by upper virtualization layers.
>
> Another piece there to add is have your VF reps implement the
> get_phys_port_name ndo,

It looks like you are returning the VF port number as phys_port_name() 
for a VF rep in en_rep.c.
Is this correct?

By default i am creating VFPR netdev with name as <pf_name>_VF<vf_num>
For ex; if enp5s0f0 is the pf name, VFPR netdev for VF0 will be enp5s0f0_vf0

If we want udev to follow this syntax should i return '_vf0'  as 
get_phys_port_name() for VF rep 0?

> where as we explain in commit cb67b832921cfa20ad79bafdc51f1745339d0557 is used
> as follows:
>
>      Port phys name (ndo_get_phys_port_name) is implemented to allow exporting
>      to user-space the VF vport number and along with the switchdev port parent
>      id (phys_switch_id) enable a udev base consistent naming scheme:
>
>      SUBSYSTEM=="net", ACTION=="add", ATTR{phys_switch_id}=="<phys_switch_id>", \
>              ATTR{phys_port_name}!="", NAME="$PF_NIC$attr{phys_port_name}"
>
>      where phys_switch_id is exposed by the PF (and VF reps) and $PF_NIC is
>      the name of the PF netdevice.
>
> Or.
