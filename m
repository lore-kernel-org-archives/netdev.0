From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v3 net-next 5/8] geneve: Add support to collect tunnel metadata.
Date: Tue, 25 Aug 2015 14:16:47 -0700
Message-ID: <CALnjE+q8y_8FbZj89R5vjfYTKUuHLXpg9g0y1vDcxsa91TxzOQ@mail.gmail.com>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
	<1440438195-5695-6-git-send-email-pshelar@nicira.com>
	<CAEP_g=_iA6FA4wboFpd_dRXnhQs4u9H7XFv5ACopv-2gy6g5Ew@mail.gmail.com>
	<CALnjE+pH3es+bSjVTGohr4xNatB=BTXcVQg3DPLwzHCr6nbz4w@mail.gmail.com>
	<CAEP_g=9Fpb9KOeqeeK_dbCdec8TvHm-iUZ4V_MWj1Mc21Qa9OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35380 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbbHYVQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 17:16:48 -0400
Received: by iodt126 with SMTP id t126so203765848iod.2
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 14:16:47 -0700 (PDT)
In-Reply-To: <CAEP_g=9Fpb9KOeqeeK_dbCdec8TvHm-iUZ4V_MWj1Mc21Qa9OQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2015 at 9:50 AM, Jesse Gross <jesse@nicira.com> wrote:
> On Mon, Aug 24, 2015 at 7:15 PM, Pravin Shelar <pshelar@nicira.com> wrote:
>> On Mon, Aug 24, 2015 at 6:42 PM, Jesse Gross <jesse@nicira.com> wrote:
>>> On Mon, Aug 24, 2015 at 10:43 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
>>>> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
>>>> index 0a6d974..c05bc13 100644
>>>> --- a/drivers/net/geneve.c
>>>> +++ b/drivers/net/geneve.c
>>>> @@ -141,10 +190,15 @@ drop:
>>>>  /* Setup stats when device is created */
>>>>  static int geneve_init(struct net_device *dev)
>>>>  {
>>>> +       struct geneve_dev *geneve = netdev_priv(dev);
>>>> +
>>>>         dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
>>>>         if (!dev->tstats)
>>>>                 return -ENOMEM;
>>>>
>>>> +       if (geneve->collect_md)
>>>> +               dev->features |= NETIF_F_NETNS_LOCAL;
>>>
>>> I was going back and forth on whether this is the right thing to do.
>>> Is it any weirder to allow this than to move a normal tunnel device
>>> across namespaces?
>>
>> Moving this device means moving all tunnels backed by this device
>> rather than specific tunnel device. Thats why it does not look right
>> to move such device.
>
> I agree it seems weird in general. There were two things that made me wonder:
>  * It doesn't appear that VXLAN or GRE do this.
>  * The use case for moving a single tunnel to a different namespace is
> to have the device and socket live in different places. I guess
> conceptually this could apply to collect_md devices as well. (Maybe to
> have harder isolation between inside and outside the tunnel?)
>
> I'm not really sure what the best answer is but at least we should be
> consistent across tunnel types.

ok, I will drop the feature.
