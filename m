From: domingo montoya <reach.domingomontoya@gmail.com>
Subject: Re: mlx5 SRIOV VLAN support
Date: Tue, 5 Jul 2016 18:13:42 +0530
Message-ID: <CAOYAsN=++QMcLwWsbx4Yfg8351ctseYMjeH6ggdgrEKS4PJaAg@mail.gmail.com>
References: <CAOYAsN=5VQM-QF+vnx=p1DtDV+912QO9kwDE-wszXmTJLc4uGA@mail.gmail.com>
 <CALzJLG8Y3N2PqbJuLTSbfWcxbWJuugZ62nJvz0_Tq7hFSN7axA@mail.gmail.com>
 <CAOYAsNmMRuqybSbLxFn4znC7SkzLx=0pppn2kb2rVX+57YAN9Q@mail.gmail.com> <CALzJLG9rVxYOiwmeQ=a6vCKZQ4UYRZvPFtW4Tt5kmJa=btDUXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35568 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932877AbcGEMno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 08:43:44 -0400
Received: by mail-wm0-f45.google.com with SMTP id z126so74051954wme.0
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 05:43:43 -0700 (PDT)
In-Reply-To: <CALzJLG9rVxYOiwmeQ=a6vCKZQ4UYRZvPFtW4Tt5kmJa=btDUXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks so much Saeed for your help.

I am thinking VLAN is not working for me probably because I might have
disabled the code which calls esw_fdb_set_vport_promisc_rule thinking
it is needed only for sniffing capabilities in the PF driver.

I will try to re-enable this code and check if VLAN works properly.

On Tue, Jul 5, 2016 at 3:23 PM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Tue, Jul 5, 2016 at 12:23 PM, domingo montoya
> <reach.domingomontoya@gmail.com> wrote:
>> Thanks so much for the reply. Please find the logs.
>>
>>
> [...]
>> # ip link show enp1s0f0
>> 3: enp1s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state
>> UP mode DEFAULT qlen 1000
>>     link/ether e4:1d:2d:c9:c8:9a brd ff:ff:ff:ff:ff:ff
>>
>> # ethtool -k enp1s0f0
>> Features for enp1s0f0:
> [...]
>> rx-vlan-filter: on
>
> I was basically looking for this and it looks ok.

Okay. Thanks a lot!
>
>>
>>
>>
>>
>> On Tue, Jul 5, 2016 at 1:41 PM, Saeed Mahameed
>> <saeedm@dev.mellanox.co.il> wrote:
>>> On Tue, Jul 5, 2016 at 10:37 AM, domingo montoya
>>> <reach.domingomontoya@gmail.com> wrote:
>>>> Hi,
>>>>
>>>> Is VLAN supported in SRIOV mode for mlx5?
>>>>
>>>
>>> For VGT mode vlan is supported by default same as bare-metal.
>>> For VST you need to use ip tool to configure VST vlan:  ip link set
>>> eth<X> vf 1 vlan 2 qos 2
>>>
>>> note: VGT mode will not work on VF if VST is configured on that VF.
>>
>> Can you please tell me how can I check if VST mode is enabled on the
>> VF from the VF driver.
>>
>
> from the VF driver you can't.
> you need to run ip link show on the PF interface of the SRIOV Hypervisor.

Sure. I'll check this.

>
>>
>>
>>>
>>>>
>>>> Can anyone please help me to:
>>>>
>>>> Enable VLAN guest tagging in mlx5 PF driver?
>>>>
>>>> Do I need to add any E-switch rules to do the same?
>>>>
>>>
>>> No,
>>> Nothing is required for VGT mode, just create the vlan on guest VF
>>> machine and work with it!
>>> E-Swtich is automatically/dynamically configured.
>>
>>
>> Is it something like when we create vlan on the guest VF, the VF
>> driver sends commands to the adapter fw and the adapter fw sends any
>> notification to the PF driver to configure Eswitch?
>>
>
> yes but for vlan lists we do nothing in PF driver e-switch
> notification since it e-switch allows all vlans by default.

Ok. It clarifies my understanding.

>
>>
>>>
>>>>
>>>> My requirement is something like this:
>>>>
>>>>
>>>> mlx5 VF driver<--------------->mlx5 PF
>>>> driver<------------------------->Network<-----------> mlx5 dedicated
>>>> driver(non-sriov)
>>>>
>>>>
>>>>
>>>> I would like to be able to send ICMP traffic between mlx5 VF driver
>>>> and mlx5 dedicated driver.
>>>>
>>>> My understanding is I should be able to do without adding any rules in
>>>> the E-switch on the PF driver as by default all traffic is allowed.
>>>>
>>>> Is this correct?
>>>>
>>>
>>> correct.
>>>
>>>>
>>>>
>>>> I tried but as this didn't work. I added ingress rules to allow VLAN
>>>> traffic and also egress rules to the E-switch ACL tables.
>>>>
>>>
>>> How did you do this ? changed the code ? by default (no VST/no spoof
>>> check) ACL tables should not be opened.
>>
>>
>> Yes. I changed the code. Okay. Now I understand that ACL tables are
>> only for VST or spoofcheck. Thanks!
>>
>
> did you change the code anywhere else ?

Yes. I disabled code under PROMISC_CHANGE thinking it was not
necessary unless I want sniffing capabilities in the PF driver.

Somehow after reading the code, I am thinking now that
esw_fdb_set_vport_promisc_rule might be needed for sending the VLAN
traffic. So I need to enable this code again.
Is my understanding correct?




>
>>>
>>>> But still i cannot see any traffic between mlx5 VF driver and mlx5
>>>> dedicated driver.
>>>>
>>>> I can see that the packets reach the CX4 adapter (mlx5 VF/mlx5 PF) but
>>>> they don't go out on the network.
>>>>
>>>> i tried configuring vlan using ip link add dev enp1s0f0 name
>>>> enp1s0f0.100 type vlan id 100 on both the mlx5 vf driver and mlx5
>>>> dedicated driver.
>>>>
>>>>
>>>
>>> Strange, should work. Please make sure VST mode is off on the VF.
>>> can you share some logs with us:
>>> on PF/VF and remote dedicated driver:
>>>
>>> ip link show <interface>
>>> ethtool -k <interface>
>>
>>
>> Sure. Wanted to check how to turn off the VST mode on the VF or make
>> sure it is off.  I have pasted the logs with this mail(at the
>> beginning).
>> I had one more doubt. If we need to disable VST mode on the VF from
>> the PF driver, using for e.g
>>
>> ip link set dev eth0 vf 2 4095,
>>
>>
>> will this command eventually call .ndo_set_vf_vlan and setup the
>> Eswitch ACL Ingress, Egress rules?
>>
>
> no, to disable you need to run 'ip link set dev eth0 vf 2 vlan 0 qos 0'
> BTW it should be disabled by default.

Okay. Thank you.
>
> to see if it disabled just run 'ip link show dev eth0' and see no vlan
> is configured on VF 2
