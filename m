From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] ovs: queue_userspace_packet: bail out if nla_nest_start
 returns NULL
Date: Wed, 03 Jul 2013 19:13:55 +0200
Message-ID: <51D45BD3.4050602@redhat.com>
References: <1372841397-10873-1-git-send-email-dborkman@redhat.com> <CAEP_g=84532Nh1wagsifOaBkCDk5eOUtG=RzWSv_Z+tPxzUOGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16154 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932597Ab3GCROI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jul 2013 13:14:08 -0400
In-Reply-To: <CAEP_g=84532Nh1wagsifOaBkCDk5eOUtG=RzWSv_Z+tPxzUOGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/03/2013 06:32 PM, Jesse Gross wrote:
> On Wed, Jul 3, 2013 at 1:49 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> The return value of nla_nest_start() is not checked, and can be NULL,
>> which is then being dereferenced in nla_nest_end(). Add a check to
>> prevent such situations.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   On top of "net-next" tree.
>>
>>   net/openvswitch/datapath.c | 4 ++++
>>   1 file changed, 4 insertions(+)
>>
>> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
>> index d12d6b8..51a3c66 100644
>> --- a/net/openvswitch/datapath.c
>> +++ b/net/openvswitch/datapath.c
>> @@ -427,6 +427,10 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
>>          upcall->dp_ifindex = dp_ifindex;
>>
>>          nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_KEY);
>> +       if (unlikely(!nla)) {
>> +               err = -ENOMEM;
>> +               goto out;
>> +       }
>
> nla_nest_start() doesn't allocate any memory, it only fails if there
> isn't enough space, so the correct error code would be -EMSGSIZE.
> However, we just calculated the correct size a few lines earlier and
> we don't double check the size anywhere else, so this doesn't make a
> lot of sense to me.

Fair enough, please drop this then.
