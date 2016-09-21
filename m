From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [net-next 01/15] i40e: Introduce VF port representor/control
 netdevs
Date: Tue, 20 Sep 2016 22:45:24 -0700
Message-ID: <57E21E74.5090707@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com> <1474429432-102772-2-git-send-email-jeffrey.t.kirsher@intel.com> <CAJ3xEMhtyrS_jKrZ8UYWDi-UjK4RuxbwUSs8H=nFqWrTgzDVdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        guru.anbalagane@oracle.com, Ilya Lesokhin <ilyal@mellanox.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Rony Efraim <ronye@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18865 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754687AbcIUFp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 01:45:27 -0400
In-Reply-To: <CAJ3xEMhtyrS_jKrZ8UYWDi-UjK4RuxbwUSs8H=nFqWrTgzDVdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 9/20/2016 9:22 PM, Or Gerlitz wrote:
> On Wed, Sep 21, 2016 at 6:43 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
>> From: Sridhar Samudrala <sridhar.samudrala@intel.com>
>> This patch enables creation of a VF Port representor/Control netdev
>> associated with each VF. These netdevs can be used to control and configure
>> VFs from PFs namespace. They enable exposing VF statistics, configuring
>> link state, mtu, fdb/vlan entries etc.
> What happens if someone does a xmit on the VF representor, does the
> packet show up @ the VF?
> and what happens of the VF xmits and there's no HW steering rule that
> matches this, does
> the frame show up @ the VF rep on the host?
TX/RX are not yet supported via VFPR netdevs in this patch series.
Will be submitting this support in the next patchset.
>
> In other words, can these VF reps serve for setting up host SW based
> switching which you
> can later offload (through TC, bridge, netfilter, etc)?
Yes. These offloads will be possible  via VFPRs.
>
> I am posing these questions because in downstream patch you are adding
> devlink support
> for set/get the e-switch mode and you declare the default mode to be switchdev.
>
> When the switchdev mode was introduced in 4.8 these RX/TX
> characteristics were defined
> to be an essential (== requirement) part for a driver to support that mode.
The current patchset introduces the basic VFPR support starting with 
exposing VF stats and
syncing link state between VFs and VFPRs.
We decided to declare the default mode to be switchdev so that the new 
code paths will get
exercised by default during normal testing.

>
> Or
>
>>      # echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
>>      # ip l show
>>      297: enp5s0f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid 6805ca2e7268 state DOWN mode DEFAULT group default qlen 1000
>>      link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:ff
>>      vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off
>>      vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off
>>      299: enp5s0f0-vf0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>>      link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
>>      300: enp5s0f0-vf1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>>      link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
