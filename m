From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] ethtool: add one ethtool option to set relax ordering mode
Date: Fri, 23 Dec 2016 07:42:51 -0800
Message-ID: <CAKgT0Ud0=fQpADLHPnZBLrG8xLGHUB20TZt1mi+GBNYJQngDCA@mail.gmail.com>
References: <1481179898-10668-1-git-send-email-maowenan@huawei.com>
 <1481179898-10668-2-git-send-email-maowenan@huawei.com> <20161221172759.1bc0d0dd@xeon-e3>
 <F95AC9340317A84688A5F0DF0246F3F20151F189@szxeml504-mbs.china.huawei.com>
 <CAKgT0Uc2ztu_iDn79zdNtsAdb-Ftu65V6YHV-sqXb6vTCTiGCQ@mail.gmail.com>
 <F95AC9340317A84688A5F0DF0246F3F20151FD1C@szxeml504-mbs.china.huawei.com>
 <1482455203.2481.31.camel@intel.com> <F95AC9340317A84688A5F0DF0246F3F20151FE86@szxeml504-mbs.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        Dingtianhong <dingtianhong@huawei.com>
To: maowenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33061 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938834AbcLWPuX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 10:50:23 -0500
Received: by mail-io0-f170.google.com with SMTP id d9so256567377ioe.0
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2016 07:50:23 -0800 (PST)
In-Reply-To: <F95AC9340317A84688A5F0DF0246F3F20151FE86@szxeml504-mbs.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 22, 2016 at 10:14 PM, maowenan <maowenan@huawei.com> wrote:
>
>
>> -----Original Message-----
>> From: Jeff Kirsher [mailto:jeffrey.t.kirsher@intel.com]
>> Sent: Friday, December 23, 2016 9:07 AM
>> To: maowenan; Alexander Duyck
>> Cc: Stephen Hemminger; netdev@vger.kernel.org; weiyongjun (A);
>> Dingtianhong
>> Subject: Re: [PATCH] ethtool: add one ethtool option to set relax ordering mode
>>
>> On Fri, 2016-12-23 at 00:40 +0000, maowenan wrote:
>> > > -----Original Message-----
>> > > From: Alexander Duyck [mailto:alexander.duyck@gmail.com]
>> > > Sent: Thursday, December 22, 2016 11:54 PM
>> > > To: maowenan
>> > > Cc: Stephen Hemminger; netdev@vger.kernel.org; jeffrey.t.kirsher@intel.
>> > > com;
>> > > weiyongjun (A); Dingtianhong
>> > > Subject: Re: [PATCH] ethtool: add one ethtool option to set relax
>> > > ordering mode
>> > >
>> > > On Wed, Dec 21, 2016 at 5:39 PM, maowenan <maowenan@huawei.com>
>> > > wrote:
>> > > >
>> > > >
>> > > > > -----Original Message-----
>> > > > > From: Stephen Hemminger [mailto:stephen@networkplumber.org]
>> > > > > Sent: Thursday, December 22, 2016 9:28 AM
>> > > > > To: maowenan
>> > > > > Cc: netdev@vger.kernel.org; jeffrey.t.kirsher@intel.com
>> > > > > Subject: Re: [PATCH] ethtool: add one ethtool option to set
>> > > > > relax ordering mode
>> > > > >
>> > > > > On Thu, 8 Dec 2016 14:51:38 +0800 Mao Wenan
>> > > > > <maowenan@huawei.com> wrote:
>> > > > >
>> > > > > > This patch provides one way to set/unset IXGBE NIC TX and RX
>> > > > > > relax ordering mode, which can be set by ethtool.
>> > > > > > Relax ordering is one mode of 82599 NIC, to enable this mode
>> > > > > > can enhance the performance for some cpu architecure.
>> > > > >
>> > > > > Then it should be done by CPU architecture specific quirks
>> > > > > (preferably in PCI
>> > > > > layer) so that all users get the option without having to do
>> > > > > manual
>> > >
>> > > intervention.
>> > > > >
>> > > > > > example:
>> > > > > > ethtool -s enp1s0f0 relaxorder off ethtool -s enp1s0f0
>> > > > > > relaxorder on
>> > > > >
>> > > > > Doing it via ethtool is a developer API (for testing) not
>> > > > > something that makes sense in production.
>> > > >
>> > > >
>> > > > This feature is not mandatory for all users, acturally relax
>> > > > ordering default configuration of 82599 is 'disable', So this
>> > > > patch gives one way to
>> > >
>> > > enable relax ordering to be selected in some performance condition.
>> > >
>> > > That isn't quite true.  The default for Sparc systems is to have it
>> > > enabled.
>> > >
>> > > Really this is something that is platform specific.  I agree with
>> > > Stephen that it would work better if this was handled as a series of
>> > > platform specific quirks handled at something like the PCI layer
>> > > rather than be a switch the user can toggle on and off.
>> > >
>> > > With that being said there are changes being made that should help
>> > > to improve the situation.  Specifically I am looking at adding
>> > > support for the DMA_ATTR_WEAK_ORDERING which may also allow us to
>> > > identify cases where you might be able to specify the DMA behavior
>> > > via the DMA mapping instead of having to make the final decision in
>> > > the device itself.
>> > >
>> > > - Alex
>> >
>> > Yes, Sparc is a special case. From the NIC driver point of view, It is
>> > no need for some ARCHs to do particular operation and compiling
>> > branch, ethtool is a flexible method for user to make decision whether
>> > on|off this feature.
>> > I think Jeff as maintainer of 82599 has some comments about this.
>>
>> My original comment/objection was that you attempted to do this change as a
>> module parameter to the ixgbe driver, where I directed you to use ethtool so
>> that other drivers could benefit from the ability to enable/disable relaxed
>> ordering.  As far as how it gets implemented in ethtool or PCI layer, makes
>> little difference to me, I only had issues with the driver specific module
>> parameter implementation, which is not acceptable.
>
>
> Thank you Jeff and Alex.
> And then I have gone through mail thread about "i40e: enable PCIe relax ordering for SPARC",
> It only works for SPARC, any other ARCH who wants to enable DMA_ATTR_WEAK_ORDERING
> feature, should define the new macro, recompile the driver module.
>
> Because of the above reasons, we implement in ethtool to give the final user a convenient
> way to on|off special feature, no need define new macro, easy to extend the new features,
> and also good benefit for other driver as Jeff referred.
>

I think the point is we shouldn't base the decision on user input.
The fact is the PCIe device control register should have a bit that
indicates if the device is allowed to enable relaxed ordering or not.
If we can guarantee that the bit is set in all the cases where it
should be set, and cleared in all the cases where it should not then
we could use something like that to determine if the device is
supposed to enable relaxed ordering instead of trying to make the
decision ourselves.

- Alex
