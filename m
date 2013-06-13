From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [ovs-dev] [PATCH net-next 4/4] openvswitch: make skb->csum
 consistent with rest of networking stack.
Date: Thu, 13 Jun 2013 09:14:25 -0700
Message-ID: <CALnjE+q9vqPFqWz_S52ngA=H9EBJEj7xTPcA=efc3MdroJDTeQ@mail.gmail.com>
References: <1371077836-19796-1-git-send-email-pshelar@nicira.com>
	<CAEP_g=_jp71ijx2=eacPWFhASE2JN++g75V=Y9TYGY40NjLiJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:48508 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754770Ab3FMQO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 12:14:26 -0400
Received: by mail-qc0-f179.google.com with SMTP id e11so1733114qcx.10
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 09:14:25 -0700 (PDT)
In-Reply-To: <CAEP_g=_jp71ijx2=eacPWFhASE2JN++g75V=Y9TYGY40NjLiJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 12, 2013 at 7:52 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Wed, Jun 12, 2013 at 3:57 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
>> index 39cd821..e6ffb82 100644
>> --- a/net/openvswitch/datapath.c
>> +++ b/net/openvswitch/datapath.c
>> @@ -406,6 +406,7 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
>>                 nskb = __vlan_put_tag(nskb, nskb->vlan_proto, vlan_tx_tag_get(nskb));
>>                 if (!nskb)
>>                         return -ENOMEM;
>> +               ovs_skb_postpush_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
>
> This shouldn't be necessary since the packet is going to userspace,
> which won't use the skb->csum value.
ok, I will update patch.
