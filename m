From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: Q: bad routing table cache entries
Date: Sun, 3 Jan 2016 20:05:39 -0500
Message-ID: <20160104010539.GC9087@oracle.com>
References: <5682665A.7090102@list.ru>
 <20151229152208.GA22423@oracle.com>
 <5683D131.4090703@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23933 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974AbcADBFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2016 20:05:50 -0500
Content-Disposition: inline
In-Reply-To: <5683D131.4090703@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (12/30/15 15:42), Stas Sergeev wrote:
> 29.12.2015 18:22, Sowmini Varadhan =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > Do you have admin control over the ubuntu router?
> > If yes, you might want to check the shared_media [#] setting=20
> > on that router for the interfaces with overlapping subnets.
> > (it is on by default, I would try turning it off).
> That didn't help, problem re-appears.

the code that sets things up for redirect is this:

  if (out_dev =3D=3D in_dev && err && IN_DEV_TX_REDIRECTS(out_dev) &&
            skb->protocol =3D=3D htons(ETH_P_IP) &&
            (IN_DEV_SHARED_MEDIA(out_dev) ||
             inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res))))
                IPCB(skb)->flags |=3D IPSKB_DOREDIRECT;

If you are still seeing the problematic redirect after disabling
shared_media, then you would need to trace through inet_addr_onlink()
to see why it was not returning false. As I said before, afaict from
reading the code, inet_addr_onlink looks right. So there may be somethi=
ng
unusual with your netmask config on in_dev/out_dev.

But even if the redirect is suppressed, sounds like the network/netmask
config is sub-optimal, since each packet gets (needlessly?) sent
up/down the router's in_dev/out_dev. That should be avoided, if possibl=
e.

--Sowmini
