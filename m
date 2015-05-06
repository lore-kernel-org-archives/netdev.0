From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 6/6] netlink: allow to listen "all" netns
Date: Wed, 06 May 2015 15:42:50 +0200
Message-ID: <554A1A5A.1020902@6wind.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com> <1430906288-5108-7-git-send-email-nicolas.dichtel@6wind.com> <20150506121022.GG25248@pox.localdomain>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, ebiederm@xmission.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:36029 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbbEFNmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 09:42:53 -0400
Received: by wgiu9 with SMTP id u9so12093899wgi.3
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 06:42:52 -0700 (PDT)
In-Reply-To: <20150506121022.GG25248@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/05/2015 14:10, Thomas Graf a =E9crit :
> On 05/06/15 at 11:58am, Nicolas Dichtel wrote:
[snip]
>> +/* This function returns true is the peer netns has an id assigned =
into the
>> + * current netns.
>> + */
>> +bool peernet_has_id(struct net *net, struct net *peer)
>> +{
>> +	return peernet2id(net, peer) >=3D 0;
>> +}
>
> Missing export?
Only used by net/netlink/af_netlink.c, which cannot be compiled as a mo=
dule.

>
>> +
>>   struct net *get_net_ns_by_id(struct net *net, int id)
>>   {
>>   	unsigned long flags;
>> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
>> index ec4adbdcb9b4..bdbde542e952 100644
>> --- a/net/netlink/af_netlink.c
>> +++ b/net/netlink/af_netlink.c
>> @@ -83,6 +83,7 @@ struct listeners {
>>   #define NETLINK_RECV_PKTINFO	0x2
>>   #define NETLINK_BROADCAST_SEND_ERROR	0x4
>>   #define NETLINK_RECV_NO_ENOBUFS	0x8
>> +#define NETLINK_LISTEN_ALL	0x10
>
> Maybe name this NETLINK_LISTEN_ALL_NSID just to make it clear?
Yes ... but it's also the name of the socket option (see include/uapi/l=
inux
/netlink.h).
I can introduce a patch before this one to rename all these private fla=
gs from
NETLINK_FOO to NETLINK_F_FOO so that they will never overlap with netli=
nk
socket options.

>
>> +		if (!file_ns_capable(sk->sk_socket->file, p->net->user_ns,
>> +				     CAP_NET_BROADCAST))
>> +			return;
>> +	}
>> +	NETLINK_CB(p->skb).net =3D p->net;
>
> Does this need a get_net()? The netns could disappear while the skb i=
s
> queued, right?
>
You're right.

Thank you for your review.
