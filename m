From: Thomas Graf <tgraf@redhat.com>
Subject: Re: [ovs-dev] [PATCH] linux: Signal datapath that unaligned Netlink
 message can be received
Date: Wed, 13 Nov 2013 10:46:53 +0100
Message-ID: <52834A8D.9040009@redhat.com>
References: <51e10053434e3afdf9940d9be7d9f0ff4788d1f7.1384184155.git.tgraf@redhat.com> <20131111155014.GC32602@nicira.com> <5280FD6D.9000609@redhat.com> <CAEP_g=_KWgmfVkNLPGYr=WjNR=UKSt3PhkqU8PE6Ug3ju2R3ig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Pfaff <blp@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Ben Hutchings <bhutchings@solarflare.com>, fleitner@redhat.com,
	dborkmann@redhat.com, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1429 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758814Ab3KMJrG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 04:47:06 -0500
In-Reply-To: <CAEP_g=_KWgmfVkNLPGYr=WjNR=UKSt3PhkqU8PE6Ug3ju2R3ig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2013 07:11 AM, Jesse Gross wrote:
> On Mon, Nov 11, 2013 at 11:53 PM, Thomas Graf <tgraf@redhat.com> wrote:
>> On 11/11/2013 04:50 PM, Ben Pfaff wrote:
>>>
>>> On Mon, Nov 11, 2013 at 04:36:24PM +0100, Thomas Graf wrote:
>>>>
>>>> Following commit (''netlink: Do not enforce alignment of last Netlink
>>>> attribute''), signal the ability to receive unaligned Netlink messages
>>>> to the datapath to enable utilization of zerocopy optimizations.
>>>>
>>>> Signed-off-by: Thomas Graf <tgraf@redhat.com>
>>>
>>>
>>> Seems OK from a userspace point of view.  I am a little concerned that
>>> downgrading userspace without deleting and re-creating the datapath
>>> (e.g. via "force-reload-kmod") will result in a totally broken setup
>>> since userspace will then drop every packet from the kernel.
>>
>>
>> Is that something that occurs occasionally in installations? Utilizing
>> the version field in the genl header could be used to track this and
>> clear user_features.
>
> It's probably a good idea. I could see us having more of these
> features flags in the future (although obviously we should try to
> avoid them if possible) and, as Ben said, it would potentially lead to
> a bad state otherwise.
>
> I'm not sure exactly what you have in mind though, can you elaborate a little?

My initial thought was to use a version field to notice the replacement
of user space. On second thought that is not required, modifying user
space to provide the user features in OVS_DP_CMD_GET as well will
overwrite the features. Resetting user_features to 0 if not features are
provided will provide backwards compatibility to versions not aware of
user features yet. Thoughts?

> (By the way, it might be a good idea to keep the same CC list on all
> of the patches. Otherwise, some people might miss parts of the
> discussion.)

I did not CC netdev because this is a pure user space patch and the
respective kernel bits are included in v5 of the kernel series.
