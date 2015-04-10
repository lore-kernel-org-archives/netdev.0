From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2-next 2/2] netns: allow to dump and monitor nsid
Date: Fri, 10 Apr 2015 16:03:35 +0200
Message-ID: <5527D837.9030506@6wind.com>
References: <1428568214-8673-1-git-send-email-nicolas.dichtel@6wind.com> <1428568214-8673-2-git-send-email-nicolas.dichtel@6wind.com> <20150409083601.GA1085@angus-think.wlc.globallogic.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:33597 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933075AbbDJODi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 10:03:38 -0400
Received: by wiax7 with SMTP id x7so16942638wia.0
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 07:03:37 -0700 (PDT)
In-Reply-To: <20150409083601.GA1085@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/04/2015 10:36, Vadim Kochan a =E9crit :
> On Thu, Apr 09, 2015 at 10:30:14AM +0200, Nicolas Dichtel wrote:
[snip]
>> +	dir =3D opendir(NETNS_RUN_DIR);
>> +	if (!dir)
>> +		return;
>> +
>> +	while ((entry =3D readdir(dir)) !=3D NULL) {
>> +		if (strcmp(entry->d_name, ".") =3D=3D 0)
>> +			continue;
>> +		if (strcmp(entry->d_name, "..") =3D=3D 0)
>> +			continue;
>> +		nsid =3D get_netnsid_from_name(entry->d_name);
>> +
>> +		if (nsid >=3D 0)
>> +			netns_map_add(nsid, entry->d_name);
>> +	}
>
> May be lib/namespace.c -> netns_foreach will be useful here  ?
I'm not fully convinced, because to use netns_foreach I need to have
another intermediate function.

[snip]
>> +	dir =3D opendir(NETNS_RUN_DIR);
>> +	if (!dir)
>> +		return -ENOENT;
>> +
>> +	while ((entry =3D readdir(dir)) !=3D NULL) {
>> +		if (strcmp(entry->d_name, ".") =3D=3D 0)
>> +			continue;
>> +		if (strcmp(entry->d_name, "..") =3D=3D 0)
>> +			continue;
>> +		id =3D get_netnsid_from_name(entry->d_name);
>> +
>> +		if (nsid =3D=3D id) {
>> +			strcpy(name, entry->d_name);
>> +			closedir(dir);
>> +			return 0;
>> +		}
>> +	}
>
> And may be here too ?
Same here. And this implies to also define a new structure to pass 'nam=
e' and
'nsid' to this new intermediate function. This will make the code more =
complex
to read.


Regards,
Nicolas
