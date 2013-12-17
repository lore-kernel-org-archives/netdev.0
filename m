From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2] linux: Signal datapath that unaligned Netlink message
 can be received
Date: Tue, 17 Dec 2013 11:21:38 -0800
Message-ID: <CAEP_g=-ZbRDnrV1LN0Kn7EpVdKnb3f0uB0NYztN_amArKhn_ig@mail.gmail.com>
References: <a960865f3ad68da1016f35085c1d84126e92f0a5.1385814128.git.tgraf@redhat.com>
 <CAEP_g=-XN+fHnLpvpQ4A9MadYH4z9uKHcRBa84vOjWaV_K_YDg@mail.gmail.com>
 <52B01EE5.4000704@redhat.com> <CAEP_g=8MtthzO=P-JpTE0jH23_EaU+rp4qiwv_Y721vxyZuFTw@mail.gmail.com>
 <52B0933B.4030107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:43060 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751474Ab3LQTWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 14:22:00 -0500
Received: by mail-ig0-f182.google.com with SMTP id c10so7114610igq.3
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 11:21:59 -0800 (PST)
In-Reply-To: <52B0933B.4030107@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 10:08 AM, Thomas Graf <tgraf@redhat.com> wrote:
> On 12/17/2013 06:49 PM, Jesse Gross wrote:
>>
>> I think there's also a potential downgrade issue if we add a new
>> feature to the list of capabilities - it won't automatically reset
>> since userspace is now using v2 of the netlink protocol. Obviously,
>> this isn't an issue yet but it we should make sure that it is
>> addressed before there is a release.
>
>
>>> Defining the NLM_F_REPLACE semantics is non trivial if we want to do
>>> more than just update the settings. I will propose this in a follow up
>>> patch.
>>
>>
>> Couldn't userspace just issue an OVS_DP_CMD_SET on start?
>
>
> Right, that works as well but introduces a small race compared to
> NLM_F_REPLACE which would be atomic. I think we can live with that.
>
> I will send a v3 of this patch with dpif-linux changed to issue
> OVS_DP_CMD_SET first and fall back to OVS_DP_CMD_NEW if no DP exists.

That sounds good to me. I have a hard time imagining a case where the
race condition would matter at all since we are still in the process
of starting up and therefore shouldn't be processing packets yet.
