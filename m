From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Create right mask with disabled megaflows
Date: Fri, 17 Oct 2014 13:40:24 -0700
Message-ID: <CALnjE+qehC2StaqpznbDBAVivoJ+-ej7KFZSXZr5GzVQ+FKYgg@mail.gmail.com>
References: <1413521745-1492-1-git-send-email-pshelar@nicira.com>
	<20141017.162058.9617975607356013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Daniele Di Proietto <ddiproietto@vmware.com>,
	Andy Zhou <azhou@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:49523 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750867AbaJQUka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 16:40:30 -0400
Received: by mail-ie0-f177.google.com with SMTP id rd18so1495987iec.22
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 13:40:25 -0700 (PDT)
In-Reply-To: <20141017.162058.9617975607356013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 17, 2014 at 1:20 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Thu, 16 Oct 2014 21:55:45 -0700
>
>> If megaflows are disabled, the userspace does not send the netlink attribute
>> OVS_FLOW_ATTR_MASK, and the kernel must create an exact match mask.
>>
>> sw_flow_mask_set() sets every bytes (in 'range') of the mask to 0xff, even the
>> bytes that represent padding for struct sw_flow, or the bytes that represent
>> fields that may not be set during ovs_flow_extract().
>> This is a problem, because when we extract a flow from a packet,
>> we do not memset() anymore the struct sw_flow to 0.
>>
>> This commit gets rid of sw_flow_mask_set() and introduces mask_set_nlattr(),
>> which operates on the netlink attributes rather than on the mask key. Using
>> this approach we are sure that only the bytes that the user provided in the
>> flow are matched.
>>
>> Also, if the parse_flow_mask_nlattrs() for the mask ENCAP attribute fails, we
>> now return with an error.
>>
>> This bug is introduced by commit 0714812134d7dcadeb7ecfbfeb18788aa7e1eaac
>> ("openvswitch: Eliminate memset() from flow_extract").
>>
>> Reported-by: Alex Wang <alexw@nicira.com>
>> Signed-off-by: Daniele Di Proietto <ddiproietto@vmware.com>
>> Signed-off-by: Andy Zhou <azhou@nicira.com>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> Why are you targetting a bug fix like this to net-next?
>
I meant it for net tree. Can you take this patch for net?

Thanks.
