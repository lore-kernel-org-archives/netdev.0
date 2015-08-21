From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv4 net-next 10/10] openvswitch: Allow attaching helpers to
 ct action
Date: Fri, 21 Aug 2015 10:39:58 -0700
Message-ID: <CALnjE+oodxeS5R2-RxUjAnUr88sEdKcmNiOpeS8gYeQ84aAvuA@mail.gmail.com>
References: <1439941188-19293-1-git-send-email-joestringer@nicira.com>
	<1439941188-19293-11-git-send-email-joestringer@nicira.com>
	<CALnjE+p7WH53qx4=OBpFAT-CDRMbuUx1c_RspQYqBdBbG1=LjA@mail.gmail.com>
	<CANr6G5xXdRynesVyQhpRXgcDbpFvrC421QiAq7x1rWAf0Vv3Aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34555 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609AbbHURj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 13:39:59 -0400
Received: by igui7 with SMTP id i7so22973895igu.1
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 10:39:58 -0700 (PDT)
In-Reply-To: <CANr6G5xXdRynesVyQhpRXgcDbpFvrC421QiAq7x1rWAf0Vv3Aw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2015 at 5:47 PM, Joe Stringer <joestringer@nicira.com> wrote:
> On 19 August 2015 at 15:57, Pravin Shelar <pshelar@nicira.com> wrote:
>> On Tue, Aug 18, 2015 at 4:39 PM, Joe Stringer <joestringer@nicira.com> wrote:
>>> Add support for using conntrack helpers to assist protocol detection.
>>> The new OVS_CT_ATTR_HELPER attribute of the ct action specifies a helper
>>> to be used for this connection.
>>>
>>> Example ODP flows allowing FTP connections from ports 1->2:
>>> in_port=1,tcp,action=ct(helper=ftp,commit),2
>>> in_port=2,tcp,ct_state=-trk,action=ct(),recirc(1)
>>> recirc_id=1,in_port=2,tcp,ct_state=+trk-new+est,action=1
>>> recirc_id=1,in_port=2,tcp,ct_state=+trk+rel,action=1
>>>
>>> Signed-off-by: Joe Stringer <joestringer@nicira.com>
>>> ---
>>> v2-v3: No change.
>>> v4: Change error code for unknown helper ENOENT->EINVAL.
>>
>> I got following compilation warning :
>>
>> net/openvswitch/conntrack.c:352:42: error: incompatible types in
>> comparison expression (different address spaces)
>
> Is this made available via another sparse flag? It looks like it's
> related to the __rcu as you've mentioned below, but I'm not seeing
> this (latest sparse, gcc-4.9.2)
>
You need to enable RCU space checker in kernel config.
