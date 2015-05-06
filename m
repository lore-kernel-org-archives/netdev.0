From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 5/6] netns: use a spin_lock to protect nsid management
Date: Wed, 06 May 2015 15:40:29 +0200
Message-ID: <554A19CD.2070608@6wind.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com> <1430906288-5108-6-git-send-email-nicolas.dichtel@6wind.com> <20150506122314.GJ25248@pox.localdomain>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, ebiederm@xmission.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36360 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930AbbEFNkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 09:40:33 -0400
Received: by wizk4 with SMTP id k4so202840559wiz.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 06:40:32 -0700 (PDT)
In-Reply-To: <20150506122314.GJ25248@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/05/2015 14:23, Thomas Graf a =E9crit :
> On 05/06/15 at 11:58am, Nicolas Dichtel wrote:
>> +/* Should be called with nsid_lock held. If a new id is assigned, t=
he bool alloc
>> + * is set to true, thus the caller knows that the new id must be no=
tified via
>> + * rtnl.
>> + */
>>   static int __peernet2id(struct net *net, struct net *peer, bool *a=
lloc)
>>   {
>>   	int id =3D idr_for_each(&net->netns_ids, net_eq_idr, peer);
>>   	bool alloc_it =3D *alloc;
>>
>> -	ASSERT_RTNL();
>> -
>>   	*alloc =3D false;
>>
>>   	/* Magic value for id 0. */
>
> If split into __peernet2id() and __peernet2id_alloc() then this could
> live with RCU protection I guess so we only take the lock when we
> actually allocate.
>
The description of idr_for_each says:
"The caller must serialize idr_for_each() vs idr_get_new() and idr_remo=
ve()."

So, if I understand well, the lock is always needed.
