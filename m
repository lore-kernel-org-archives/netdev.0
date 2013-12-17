From: Thomas Graf <tgraf@redhat.com>
Subject: Re: [PATCH v2] linux: Signal datapath that unaligned Netlink message
 can be received
Date: Tue, 17 Dec 2013 10:52:37 +0100
Message-ID: <52B01EE5.4000704@redhat.com>
References: <a960865f3ad68da1016f35085c1d84126e92f0a5.1385814128.git.tgraf@redhat.com> <CAEP_g=-XN+fHnLpvpQ4A9MadYH4z9uKHcRBa84vOjWaV_K_YDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6023 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090Ab3LQJxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 04:53:44 -0500
In-Reply-To: <CAEP_g=-XN+fHnLpvpQ4A9MadYH4z9uKHcRBa84vOjWaV_K_YDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2013 02:23 AM, Jesse Gross wrote:
> On Sat, Nov 30, 2013 at 4:25 AM, Thomas Graf <tgraf@redhat.com> wrote:
>> diff --git a/lib/dpif-linux.c b/lib/dpif-linux.c
>> index 6c482d0..2d8a1aa 100644
>> --- a/lib/dpif-linux.c
>> +++ b/lib/dpif-linux.c
>> @@ -73,6 +73,7 @@ struct dpif_linux_dp {
>>       /* Attributes. */
>>       const char *name;                  /* OVS_DP_ATTR_NAME. */
>>       const uint32_t *upcall_pid;        /* OVS_DP_ATTR_UPCALL_PID. */
>> +    uint32_t user_features;            /* OVS_DP_ATTR_USER_FEATURES */
>>       struct ovs_dp_stats stats;         /* OVS_DP_ATTR_STATS. */
>>       struct ovs_dp_megaflow_stats megaflow_stats;
>>                                          /* OVS_DP_ATTR_MEGAFLOW_STATS.*/
>> @@ -228,6 +229,7 @@ dpif_linux_open(const struct dpif_class *class OVS_UNUSED, const char *name,
>>           dp_request.cmd = OVS_DP_CMD_NEW;
>>           upcall_pid = 0;
>>           dp_request.upcall_pid = &upcall_pid;
>> +        dp_request.user_features |= OVS_DP_F_UNALIGNED;
>>       } else {
>>           dp_request.cmd = OVS_DP_CMD_GET;
>>       }
>
> Does this handle the case where we are opening an existing datapath
> and need to update the features?

The patch (''openvswitch: Drop user features if old user space attempted
to create datapath'') takes care of resetting the features for the
downgrade case. The upgrade case with a persistent datapath object is
currently not implemented. The datapath object needs to be recreated.

Defining the NLM_F_REPLACE semantics is non trivial if we want to do
more than just update the settings. I will propose this in a follow up
patch.
