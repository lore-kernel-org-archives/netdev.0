From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: ip_tunnel: Remove gratuitous skb scrubbing
Date: Wed, 15 Apr 2015 12:28:46 +0200
Message-ID: <552E3D5E.6090103@6wind.com>
References: <20150415100107.GA3655@gondor.apana.org.au> <552E3B7A.2040701@6wind.com> <20150415102229.GA3917@gondor.apana.org.au>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:34362 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754551AbbDOK2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 06:28:49 -0400
Received: by wgso17 with SMTP id o17so41838239wgs.1
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 03:28:48 -0700 (PDT)
In-Reply-To: <20150415102229.GA3917@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/04/2015 12:22, Herbert Xu a =E9crit :
> On Wed, Apr 15, 2015 at 12:20:42PM +0200, Nicolas Dichtel wrote:
>> Le 15/04/2015 12:01, Herbert Xu a =E9crit :
>>> The commit ea23192e8e577dfc51e0f4fc5ca113af334edff9 ("tunnels:
>>> harmonize cleanup done on skb on rx path") broke anyone trying to
>>> use netfilter marking across IPv4 tunnels.  As the commit message
>>> did not give any justification for this (in fact it shouldn't
>>> even be touching the tx path), I can only assume that it was a typo=
=2E
>> If I remember well, this was discussed on netdev (CC Eric). The goal=
 of this
>> patch was, like the title said, to hamonize packets processing in tu=
nnels.
>> I'm not against to keep the mark, but I think patching skb_scrub_pac=
ket is
>> better. With your patch, ip6tnl, gre6, etc. still drops the mark. An=
d at the
>> end, it's not consistant.
>>
>> What about something like this:
>
> Yes this is better.  I'm currently auditing all the other bits
> that are cleared to see if there is anything else that we should
> preserve for tunneling.
Here is the thread about the mark:
http://thread.gmane.org/gmane.linux.network/246876/focus=3D274528
