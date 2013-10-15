From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next] openvswitch: fix vport-netdev unregister
Date: Tue, 15 Oct 2013 09:53:20 -0700
Message-ID: <CAMEtUuxysgzNqeBpBQ-ajLtymYCvEF-GMiUcQuy1b-QA=dFhdw@mail.gmail.com>
References: <1381722652-3689-1-git-send-email-ast@plumgrid.com>
	<CAEP_g=-hkjjph8qO8MQL=BBA8MnaUdE2vTy3jN+m7Vh5skfa6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Pirko <jiri@resnulli.us>, Cong Wang <amwang@redhat.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:49618 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932228Ab3JOQxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 12:53:21 -0400
Received: by mail-wi0-f179.google.com with SMTP id hm4so3709735wib.0
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 09:53:20 -0700 (PDT)
In-Reply-To: <CAEP_g=-hkjjph8qO8MQL=BBA8MnaUdE2vTy3jN+m7Vh5skfa6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 15, 2013 at 8:31 AM, Jesse Gross <jesse@nicira.com> wrote:
> On Sun, Oct 13, 2013 at 8:50 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
>> index c323567..ffa429a 100644
>> --- a/net/openvswitch/dp_notify.c
>> +++ b/net/openvswitch/dp_notify.c
>> @@ -59,15 +59,9 @@ void ovs_dp_notify_wq(struct work_struct *work)
>>                         struct hlist_node *n;
>>
>>                         hlist_for_each_entry_safe(vport, n, &dp->ports[i], dp_hash_node) {
>> -                               struct netdev_vport *netdev_vport;
>> -
>>                                 if (vport->ops->type != OVS_VPORT_TYPE_NETDEV)
>>                                         continue;
>> -
>> -                               netdev_vport = netdev_vport_priv(vport);
>> -                               if (netdev_vport->dev->reg_state == NETREG_UNREGISTERED ||
>> -                                   netdev_vport->dev->reg_state == NETREG_UNREGISTERING)
>> -                                       dp_detach_port_notify(vport);
>> +                               dp_detach_port_notify(vport);
>
> Doesn't this free *all* ports of type OVS_VPORT_TYPE_NETDEV when any
> one of them is removed?

sorry. not sure what I was thinking on Sunday evening. will respin
