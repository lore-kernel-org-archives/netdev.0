From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: bpf filter : support for vlan tag
Date: Fri, 19 Oct 2012 22:53:20 +0200
Message-ID: <CAD6jFURcGt-xwE7WGXPvfGZ1JXAWC+sVNnN+gbpEyQSJYvxDnQ@mail.gmail.com>
References: <CAOxq_8MqMatY2+GA6+mHjj5V=Xe7Y8BmuX4r6cz5nChU5C1Vzw@mail.gmail.com>
	<1350369998.3954.563.camel@edumazet-glaptop>
	<CAD6jFUTn98+i_0eh6gc-CYgVXHNLbZdZmV6==mL+duFM-oNRmg@mail.gmail.com>
	<1350386917.3954.890.camel@edumazet-glaptop>
	<CAOxq_8NWMy2gL4QQv_e2hjHZZnFyFghmXzN5EnrXz3SRULxR6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Ani Sinha <ani@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41693 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526Ab2JSUx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 16:53:28 -0400
Received: from [78.46.5.203] (helo=sslproxy01.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TPJZP-0001F9-7A
	for netdev@vger.kernel.org; Fri, 19 Oct 2012 22:53:27 +0200
Received: from [209.85.215.174] (helo=mail-ea0-f174.google.com)
	by sslproxy01.your-server.de with esmtpsa (TLSv1:RC4-SHA:128)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TPJZT-0005m2-Uw
	for netdev@vger.kernel.org; Fri, 19 Oct 2012 22:53:31 +0200
Received: by mail-ea0-f174.google.com with SMTP id c13so278050eaa.19
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 13:53:20 -0700 (PDT)
In-Reply-To: <CAOxq_8NWMy2gL4QQv_e2hjHZZnFyFghmXzN5EnrXz3SRULxR6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 19, 2012 at 8:32 PM, Ani Sinha <ani@aristanetworks.com> wrote:
> how about this?
>
> On Tue, Oct 16, 2012 at 4:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> @@ -341,6 +342,12 @@ load_b:
>>                 case BPF_S_ANC_CPU:
>>                         A = raw_smp_processor_id();
>>                         continue;
>> +               case BPF_S_ANC_VLAN_TAG:
>> +                       A = vlan_tx_tag_get(skb);
>> +                       continue;
>> +               case BPF_S_ANC_VLAN_TAG_PRESENT:
>> +                       A = !!vlan_tx_tag_present(skb);
>> +                       continue;
>>                 case BPF_S_ANC_NLATTR: {
>>                         struct nlattr *nla;
>
>
> +               case BPF_S_ANC_VLAN_TAG:
> +                       if (!vlan_tx_tag_present(skb)) {
> +                               return 0;
> +                       }
> +                       A = vlan_tx_tag_get(skb);
> +                       continue;

I didn't look into the code, but I assume that if no vlan is present,
then vlan_tx_tag_get might return 0 anyway. Also, your return is
simply wrong, since then after this instruction you leave the *whole*
BPF machine ignoring the rest of the filter program to process ...

> +               case BPF_S_ANC_VLAN_TAG_PRESENT :
> +                       A = !! vlan_tx_tag_present(skb);
> +                       continue;
>
> Now, is there any particular reason we are not using clan_get_tag() api?
>
> Thanks
> ani
