From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH net v2] i40e: Fix limit imprecise of the
 number of MAC/VLAN that can be added for VFs
Date: Fri, 29 Sep 2017 08:04:49 -0700
Message-ID: <CAKgT0UdKnx1uOR7z-9KyFWWXRF4KWWCcE1sjZ0mnQBX6gKNang@mail.gmail.com>
References: <1506564064-10740-1-git-send-email-wangyunjian@huawei.com>
 <CAKgT0UcsnLUWU8qedNrv+bhbgJ6SC9zWyc7oR9gObcYo2atN5g@mail.gmail.com> <34EFBCA9F01B0748BEB6B629CE643AE60C64BFF6@dggemm513-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Netdev <netdev@vger.kernel.org>, caihe <caihe@huawei.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: wangyunjian <wangyunjian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:56985 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752202AbdI2PEv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 11:04:51 -0400
Received: by mail-qt0-f193.google.com with SMTP id l25so1962690qtf.13
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 08:04:51 -0700 (PDT)
In-Reply-To: <34EFBCA9F01B0748BEB6B629CE643AE60C64BFF6@dggemm513-mbx.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 29, 2017 at 2:13 AM, wangyunjian <wangyunjian@huawei.com> wrote:
>
>
>> -----Original Message-----
>> From: Alexander Duyck [mailto:alexander.duyck@gmail.com]
>> Sent: Thursday, September 28, 2017 11:44 PM
>> To: wangyunjian <wangyunjian@huawei.com>
>> Cc: David Miller <davem@davemloft.net>; Jeff Kirsher
>> <jeffrey.t.kirsher@intel.com>; Sergei Shtylyov
>> <sergei.shtylyov@cogentembedded.com>; Netdev
>> <netdev@vger.kernel.org>; caihe <caihe@huawei.com>; intel-wired-lan
>> <intel-wired-lan@lists.osuosl.org>
>> Subject: Re: [Intel-wired-lan] [PATCH net v2] i40e: Fix limit imprecise of the
>> number of MAC/VLAN that can be added for VFs
>>
>> On Wed, Sep 27, 2017 at 7:01 PM, w00273186 <wangyunjian@huawei.com>
>> wrote:
>> > From: Yunjian Wang <wangyunjian@huawei.com>
>> >
>> > Now it doesn't limit the number of MAC/VLAN strictly. When there is more
>> > elements in the virtchnl MAC/VLAN list, it can still add successfully.
>>
>> You could still add but should you. I'm not clear from this patch
>> description what this is supposed to be addressing. If you enable the
>> "trust" flag for a VF via the "ip link set dev <iface> vf <vfnum>
>> trust on" it can make use of any resources on the device, but without
>> that there is an upper limit that is supposed to be enforced to
>> prevent the VF from making use of an excessive amount of resources.
>> That is what is being enforced by the code you are moving out of the
>> way below.
>
> I don't enable the "trust" flag for a VF. But this script can successfully add
> MACs more than I40E_VC_MAX_MAC_ADDR_PER_VF(12) in VM. It has
> same problem with VLAN.
>
> Test script:
>
> for((i=10;i<50;i++))
> do
>     ipmaddr add 01:00:5e:01:02:$i  dev eth0
> done
>
> for ((i=1;i<40;i++))
> do
>     ip link add link eth0 name eth0.$i type vlan id $i
> done
>

Okay, thanks for the info. I can see if we can address the issue in a
way that prevents us from adding the filters to the hardware before we
return the result indicating if we can support it or not.

- Alex
