From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v5 1/7] vxlan: Restructure vxlan socket apis.
Date: Wed, 31 Jul 2013 20:00:12 -0700
Message-ID: <CALnjE+oA6Cp3whfdWVkkRd-jYsYdbKM9u_bwPwKq2tRdtnJdQQ@mail.gmail.com>
References: <1375312463-18574-1-git-send-email-pshelar@nicira.com>
	<20130731164521.09c43fb8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:34293 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752594Ab3HADAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 23:00:14 -0400
Received: by mail-qe0-f41.google.com with SMTP id a11so853645qen.28
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 20:00:13 -0700 (PDT)
In-Reply-To: <20130731164521.09c43fb8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 4:45 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 31 Jul 2013 16:14:23 -0700
> Pravin B Shelar <pshelar@nicira.com> wrote:
>
>>       /* Disable multicast loopback */
>>       inet_sk(sk)->mc_loop = 0;
>> +     spin_lock(&vn->sock_lock);
>> +     hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
>> +     spin_unlock(&vn->sock_lock);
>>
>
> This change could potentially put two of the sockets with the
> same port in the list.
>
> There is an existing check in vxlan_sock_work to handle this
> now. It does:
>   create new socket (no locks)
>
>   spin_lock
>   if (udp_socket with that port exists)
>       drop new socket
>   else
>       add to list
>   spin_unlock
>
> Your code seems to immediately put it on the list which
> will cause duplicates if race occurs.

I do not think it is possible.
Create new socket does bind which shld fail on same port. So there
would be only one vxlan-sock entry in socket table.
