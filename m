From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net v4] rtnl/bond: don't send rtnl msg for unregistered
 iface
Date: Wed, 13 May 2015 14:36:32 +0200
Message-ID: <55534550.5060405@6wind.com>
References: <20150512161402.GC2081@nanopsycho> <1431519582-4219-1-git-send-email-nicolas.dichtel@6wind.com> <20150513122418.GA2138@nanopsycho.mtl.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36215 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965234AbbEMMgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 08:36:35 -0400
Received: by wizk4 with SMTP id k4so196655513wiz.1
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 05:36:34 -0700 (PDT)
In-Reply-To: <20150513122418.GA2138@nanopsycho.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/05/2015 14:24, Jiri Pirko a =E9crit :
> Wed, May 13, 2015 at 02:19:42PM CEST, nicolas.dichtel@6wind.com wrote=
:
[snip]
>> The patch fixes the spotted bug by checking in bond driver if the in=
terface
>> is registered before calling the notifier chain.
>> It also adds a check in rtmsg_ifinfo() to prevent this kind of bug i=
n the
>> future.
[snip]
>> --- a/net/core/rtnetlink.c
>> +++ b/net/core/rtnetlink.c
>> @@ -2415,6 +2415,9 @@ void rtmsg_ifinfo(int type, struct net_device =
*dev, unsigned int change,
>> {
>> 	struct sk_buff *skb;
>>
>> +	if (dev->reg_state !=3D NETREG_REGISTERED)
>> +		return;
>> +
>
> This is redundant now that you check it in __bond_opt_set.
As said in the commit log ;-)

>
> Sorry to be a pain Nicolas :/
>
Yeah, I see that you don't want this check ;-)
In fact, I don't really understand why because it does not harm and it =
prevents
to have again the same bug.

Does anyone else have an opinion on that?
