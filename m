From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 09/17] bridge: add API to notify bridge driver
 of learned FBD on offloaded device
Date: Tue, 25 Nov 2014 22:22:44 -0500
Message-ID: <54754784.2060009@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-10-git-send-email-jiri@resnulli.us> <54750669.4090406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:55552 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbaKZDWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 22:22:52 -0500
Received: by mail-ig0-f170.google.com with SMTP id r2so7893578igi.5
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 19:22:52 -0800 (PST)
In-Reply-To: <54750669.4090406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 17:44, Florian Fainelli wrote:
> On 25/11/14 02:28, Jiri Pirko wrote:

>> @@ -101,6 +101,7 @@ struct net_bridge_fdb_entry
>>   	unsigned char			is_local;
>>   	unsigned char			is_static;
>>   	unsigned char			added_by_user;
>> +	unsigned char			added_by_external_learn;
>
> Pheww, we could be saving some memory footprint here by using different
> types here ;)

I tried to bring up this issue earlier.
Unfortuately about 15 different things being transfered over bridge
netlink use 8 bits for representing a bit of information.
A bitmap selector would be a lot more efficient. Not unusual to have a
few hundred thousand entries.

cheers,
jamal

> --
> Florian
>
