From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] ethtool: add one ethtool option to set relax ordering mode
Date: Thu, 22 Dec 2016 07:53:42 -0800
Message-ID: <CAKgT0Uc2ztu_iDn79zdNtsAdb-Ftu65V6YHV-sqXb6vTCTiGCQ@mail.gmail.com>
References: <1481179898-10668-1-git-send-email-maowenan@huawei.com>
 <1481179898-10668-2-git-send-email-maowenan@huawei.com> <20161221172759.1bc0d0dd@xeon-e3>
 <F95AC9340317A84688A5F0DF0246F3F20151F189@szxeml504-mbs.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        Dingtianhong <dingtianhong@huawei.com>
To: maowenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34409 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965431AbcLVPxs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 10:53:48 -0500
Received: by mail-io0-f177.google.com with SMTP id p42so233962812ioo.1
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2016 07:53:48 -0800 (PST)
In-Reply-To: <F95AC9340317A84688A5F0DF0246F3F20151F189@szxeml504-mbs.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2016 at 5:39 PM, maowenan <maowenan@huawei.com> wrote:
>
>
>> -----Original Message-----
>> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
>> Sent: Thursday, December 22, 2016 9:28 AM
>> To: maowenan
>> Cc: netdev@vger.kernel.org; jeffrey.t.kirsher@intel.com
>> Subject: Re: [PATCH] ethtool: add one ethtool option to set relax ordering mode
>>
>> On Thu, 8 Dec 2016 14:51:38 +0800
>> Mao Wenan <maowenan@huawei.com> wrote:
>>
>> > This patch provides one way to set/unset IXGBE NIC TX and RX relax
>> > ordering mode, which can be set by ethtool.
>> > Relax ordering is one mode of 82599 NIC, to enable this mode can
>> > enhance the performance for some cpu architecure.
>>
>> Then it should be done by CPU architecture specific quirks (preferably in PCI
>> layer) so that all users get the option without having to do manual intervention.
>>
>> > example:
>> > ethtool -s enp1s0f0 relaxorder off
>> > ethtool -s enp1s0f0 relaxorder on
>>
>> Doing it via ethtool is a developer API (for testing) not something that makes
>> sense in production.
>
>
> This feature is not mandatory for all users, acturally relax ordering default configuration of 82599 is 'disable',
> So this patch gives one way to enable relax ordering to be selected in some performance condition.

That isn't quite true.  The default for Sparc systems is to have it enabled.

Really this is something that is platform specific.  I agree with
Stephen that it would work better if this was handled as a series of
platform specific quirks handled at something like the PCI layer
rather than be a switch the user can toggle on and off.

With that being said there are changes being made that should help to
improve the situation.  Specifically I am looking at adding support
for the DMA_ATTR_WEAK_ORDERING which may also allow us to identify
cases where you might be able to specify the DMA behavior via the DMA
mapping instead of having to make the final decision in the device
itself.

- Alex
