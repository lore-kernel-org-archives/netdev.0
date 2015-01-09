From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: IPsec workshop at netdev01?
Date: Fri, 09 Jan 2015 13:30:38 +0800
Message-ID: <54AF677E.9080108@gmail.com>
References: <20150106101936.GC31458@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	"Du, Fan" <fan.du@intel.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:48331 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbbAIFeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 00:34:16 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so16397175pad.1
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 21:34:16 -0800 (PST)
In-Reply-To: <20150106101936.GC31458@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B401=E6=9C=8806=E6=97=A5 18:19, Steffen Klassert =E5=
=86=99=E9=81=93:
> Is there any interest in doing an IPsec workshop at netdev01?
>
> This mail is to probe if we can gather enough discussion topics to ru=
n
> such a workshop. So if someone is interested to attend and/or has a
> related discussion topic, please let me know.
>
> The idea to do this workshop came yesterday, so I'm still collecting
> topics I'm interested in. Some things that came immediately to my min=
d
> are:
>
> - Our IPsec policy/state lookups are still hashlist based on slowpath=
 with
>    a flowcache to do fast lookups for traffic flows we have already s=
een.
>    This flowcache has similar issues like the ipv4 routing chache had=
=2E
>    Is the flowcache an appropriate lookup method on the long run or s=
hould
>    we at least think about an additional alternative lookup method?
>
> - We still lack a 32/64 bit compatibiltiy layer for IPsec, this issue
>    comes up from time to time. Some solutions were proposed in the pa=
st
>    but all had problems. The current behaviour is broken if someone t=
ries
>    to configure IPsec with 32 bit tools on a 64 bit machine. Can we g=
et
>    this right somehow or is it better to just return an error in this=
 case?

Before a clean solution show up, I think it's better to warn user in so=
me way
like http://patchwork.ozlabs.org/patch/323842/ did. Otherwise, many peo=
ple
who stuck there will always spend time and try to fix this issue in wha=
tever way.

> - Changing the system time can lead to unexpected SA lifetime changes=
=2E The
>    discussion on the list did not lead to a conclusion on how to fix =
this.
>    What is the best way to get this fixed?

I rise this issue long ago before, the culprit is SA lifetime is marked=
 by wall clock.
In a reasonable way it should be marked as monotonic boot time(counting=
 suspend time
as well). Then every thing will be work correctly. I have such a patch =
works correctly.
EXCEPT: SA migration, where SA lifetime comes from outside.
I didn't look at SA migration part though, so any comments? Steffen


--=20
No zuo no die but I have to try.
