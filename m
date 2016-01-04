From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Mon, 4 Jan 2016 04:32:49 +0300
Message-ID: <5689CBC1.7030402@list.ru>
References: <5682665A.7090102@list.ru> <20151229152208.GA22423@oracle.com>
 <5683D131.4090703@list.ru> <20160104010539.GC9087@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback4.mail.ru ([94.100.181.169]:58239 "EHLO
	fallback4.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbcADBXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2016 20:23:47 -0500
Received: from smtp11.mail.ru (smtp11.mail.ru [94.100.179.252])
	by fallback4.mail.ru (mPOP.Fallback_MX) with ESMTP id 000E1E1F72F
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 04:23:43 +0300 (MSK)
In-Reply-To: <20160104010539.GC9087@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

04.01.2016 04:05, Sowmini Varadhan =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On (12/30/15 15:42), Stas Sergeev wrote:
>> 29.12.2015 18:22, Sowmini Varadhan =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> Do you have admin control over the ubuntu router?
>>> If yes, you might want to check the shared_media [#] setting
>>> on that router for the interfaces with overlapping subnets.
>>> (it is on by default, I would try turning it off).
>> That didn't help, problem re-appears.
> the code that sets things up for redirect is this:
>
>    if (out_dev =3D=3D in_dev && err && IN_DEV_TX_REDIRECTS(out_dev) &=
&
>              skb->protocol =3D=3D htons(ETH_P_IP) &&
>              (IN_DEV_SHARED_MEDIA(out_dev) ||
>               inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res))))
>                  IPCB(skb)->flags |=3D IPSKB_DOREDIRECT;
>
> If you are still seeing the problematic redirect after disabling
> shared_media, then you would need to trace through inet_addr_onlink()
> to see why it was not returning false. As I said before, afaict from
> reading the code, inet_addr_onlink looks right. So there may be somet=
hing
> unusual with your netmask config on in_dev/out_dev.
OK, thanks for the hint. Looks like a small function, I'll
trace it with systemtap a week later.
But I am more worrying about accepting such a redirects.
Almost certainly a bug.

> But even if the redirect is suppressed, sounds like the network/netma=
sk
> config is sub-optimal, since each packet gets (needlessly?) sent
> up/down the router's in_dev/out_dev. That should be avoided, if possi=
ble.
Since I don't have a root access to the 192.168.0.1, I can't change
the masks. But curing the 192.168.8.1 router would give enough
of a relief too.
