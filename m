From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH v2 2/6] i40e: Introduce VF
 Port Representator(VFPR) netdevs.
Date: Thu, 05 Jan 2017 16:42:04 -0800
Message-ID: <586EE7DC.4000204@intel.com>
References: <1483466874-2962-1-git-send-email-sridhar.samudrala@intel.com>       <1483466874-2962-3-git-send-email-sridhar.samudrala@intel.com> <1483652771.25700.41.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        davem@davemloft.net, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:25538 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1032304AbdAFAmF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 19:42:05 -0500
In-Reply-To: <1483652771.25700.41.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 1/5/2017 1:46 PM, Jeff Kirsher wrote:
> On Tue, 2017-01-03 at 10:07 -0800, Sridhar Samudrala wrote:
>> VF Port Representator netdevs are created for each VF if the switch mode
>> is set to 'switchdev'. These netdevs can be used to control and configure
>> VFs from PFs namespace. They enable exposing VF statistics, configure and
>> monitor link state, mtu, filters, fdb/vlan entries etc. of VFs.
>> Broadcast filters are not enabled in switchdev mode.
>>
>> Sample script to create VF port representors
>> # rmmod i40e; modprobe i40e
>> # devlink dev eswitch set pci/0000:05:00.0 mode switchdev
>> # echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
>> # ip l show
>> 297: enp5s0f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid
>> 6805ca2e7268 state DOWN mode DEFAULT group default qlen 1000
>>       link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:ff
>>       vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state auto,
>> trust off
>>       vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state auto,
>> trust off
>> 299: enp5s0f0-vf0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
>> mode DEFAULT group default qlen 1000
>>       link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
>> 300: enp5s0f0-vf1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
>> mode DEFAULT group default qlen 1000
>>       link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
>>
>> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
>> ---
>>   drivers/net/ethernet/intel/i40e/i40e_main.c        |  21 ++-
>>   drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 154
>> ++++++++++++++++++++-
>>   drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  14 ++
>>   3 files changed, 182 insertions(+), 7 deletions(-)
> This does not apply cleanly because it is based on an older version of
> i40e_virtchnl_pf.c file.  It appears that i40e has been updated to use
> "i40e_add_filter()" yet your patch still uses "i40e_add_mac_filter()".
I am not using i40e_add_mac_filter() in my patches. I only i40e_add_filter()
These patches are against davem's net-next kernel

>
> We need to clarify what the "right way" is to add filters and use the
> correct function.
>
> Dropping this series and will await v3, please address the other feedback
> from Or Gerlitz and Jiri Pirko as well in your updated series.

Sure. I will be submitting a v3 soon addressing the review comments.
