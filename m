From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [net-next 01/15] i40e: Introduce VF port representor/control
 netdevs
Date: Wed, 21 Sep 2016 09:59:32 -0700
Message-ID: <57E2BC74.5040905@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com> <1474429432-102772-2-git-send-email-jeffrey.t.kirsher@intel.com> <CAJ3xEMhtyrS_jKrZ8UYWDi-UjK4RuxbwUSs8H=nFqWrTgzDVdw@mail.gmail.com> <57E21E74.5090707@intel.com> <CAJ3xEMgMkz1FZ-QObMvc28JQT0Osrf-k7_RfanUYkYP=F8jZGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        guru.anbalagane@oracle.com, Ilya Lesokhin <ilyal@mellanox.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Rony Efraim <ronye@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:16201 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933504AbcIUQ7e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 12:59:34 -0400
In-Reply-To: <CAJ3xEMgMkz1FZ-QObMvc28JQT0Osrf-k7_RfanUYkYP=F8jZGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 9/21/2016 12:04 AM, Or Gerlitz wrote:
> On Wed, Sep 21, 2016 at 8:45 AM, Samudrala, Sridhar
> <sridhar.samudrala@intel.com> wrote:
>> On 9/20/2016 9:22 PM, Or Gerlitz wrote:
>>> On Wed, Sep 21, 2016 at 6:43 AM, Jeff Kirsher
>>> <jeffrey.t.kirsher@intel.com> wrote:
>>>> From: Sridhar Samudrala <sridhar.samudrala@intel.com>
>>>> This patch enables creation of a VF Port representor/Control netdev
>>>> associated with each VF. These netdevs can be used to control and
>>>> configure
>>>> VFs from PFs namespace. They enable exposing VF statistics, configuring
>>>> link state, mtu, fdb/vlan entries etc.
>>> What happens if someone does a xmit on the VF representor, does the
>>> packet show up @ the VF?
>>> and what happens of the VF xmits and there's no HW steering rule that
>>> matches this, does
>>> the frame show up @ the VF rep on the host?
>> TX/RX are not yet supported via VFPR netdevs in this patch series.
>> Will be submitting this support in the next patchset.
> Okay, good.
>
>>> In other words, can these VF reps serve for setting up host SW based
>>> switching which you
>>> can later offload (through TC, bridge, netfilter, etc)?
>> Yes. These offloads will be possible  via VFPRs.
> cool
>
>>> I am posing these questions because in downstream patch you are adding
>>> devlink support
>>> for set/get the e-switch mode and you declare the default mode to be switchdev.
>>> When the switchdev mode was introduced in 4.8 these RX/TX
>>> characteristics were defined
>>> to be an essential (== requirement) part for a driver to support that mode.
>> The current patchset introduces the basic VFPR support starting with
>> exposing VF stats and syncing link state between VFs and VFPRs.
>> We decided to declare the default mode to be switchdev so that the new code
>> paths will get exercised by default during normal testing.
> so what happens after this patchset is applied and before the future
> work is submitted?
> RX/TX slow path through the VFPRs isn't supported and what about fast
> path? in other words
> what happens when someone loads the driver, sets SRIOV (--> the driver
> set itself to switchdev mode
> and VFPRs are created) and then a VF sends a packet? do you still put
> into the HW the legacy DMAC
> based switching rules? I am not following...

The VF driver requests adding the dmac based filter rules via mailbox 
messages to PF and that is
not changed in this patchset.
Once we have VFPR TX/RX support, we will not allow the VF driver to add 
these rules, Instead a host based
program will be able to add these rules to enable the fast path.

Thanks
Sridhar
