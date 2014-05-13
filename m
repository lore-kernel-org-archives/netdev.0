From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 0/3] Make mark-based routing work better with multiple
 separate networks.
Date: Tue, 13 May 2014 09:09:12 -0700
Message-ID: <537243A8.2060007@candelatech.com>
References: <1399657021-26082-1-git-send-email-lorenzo@google.com> <CACP96tS0ikGfx85HX6t1w8+AENuiJu2N2-AyiJP+=VBohKjb4A@mail.gmail.com> <CAKD1Yr1ey0j03OtO3_tD+AREQwnk1J9Mx60-TcEP9QwEy4tdAw@mail.gmail.com> <CACP96tQO8PWyOKxR5gWWx4VvjjcTmkLhGHr_P2-WBCDEJpqL8Q@mail.gmail.com> <CAKD1Yr0z40vY8ucGDuLo8rPDudtHeOeMPbN_vfSSS_K4KjCffg@mail.gmail.com> <CACP96tTRQqvQM6UTuqtVonZJW3LaHkBZkkpH+zCZa=GjHAEy+Q@mail.gmail.com> <CAKD1Yr2YtX9eGeFOeMb=s3_yqhhJgWEb+G0JH26UPRDPfZ5MgQ@mail.gmail.com> <CACP96tSF=3ogg+Gv6GiOuUxF=kL_6FE0f_P1Efcg7-RKWs++yA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
	netdev <netdev@vger.kernel.org>, JP Abgrall <jpa@google.com>,
	David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: sowmini varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:33654 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758086AbaEMQJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 12:09:13 -0400
In-Reply-To: <CACP96tSF=3ogg+Gv6GiOuUxF=kL_6FE0f_P1Efcg7-RKWs++yA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/2014 08:38 AM, sowmini varadhan wrote:
> On Tue, May 13, 2014 at 11:28 AM, Lorenzo Colitti <lorenzo@google.com> wrote:
> 
>> You can't use macvlan if you're not using interfaces that don't have
>> MAC addresses such as tun devices, 4G interfaces, and so on.
> 
> So to repeat, "what problem do you need to solve?" You indicated
> that
> " As described in the patch cover letter, one of the things I'm trying
>   to do is have fwmarks select between multiple separate networks, which
>   may be on multiple physical interfaces. I also want applications to be
>   able to listen for connections from all networks using a single
>   listening socket. I don't care about network isolation."

For what it's worth, we have had good luck doing something similar to the
marking rules with a private patch some years ago.  Then, we backed that out
and ran similar rules based on source/dest ports and IP addrs.  You can do these
routing tricks using standard kernels, but it is not very efficient because you
end up with hundreds or thousands of ip rules.

We found this approach much easier to deal with than using namespaces, though
when we started namespaces did not even exist so maybe we are biased.

If I ever have time to hack on this again, I'd like to optimize the ip rules
so that they can be bound to a specific interface so that the cost of having
lots of rules is not so high...


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
