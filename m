From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Question: should local address be expired when updating PMTU?
Date: Mon, 30 Mar 2015 12:32:12 +0200
Message-ID: <20150330103210.GI3311@secunet.com>
References: <54CF3348.40207@huawei.com>
 <20150203092845.GT13046@secunet.com>
 <54D0A8DB.4010106@huawei.com>
 <20150203120140.GU13046@secunet.com>
 <54D17D1A.3020706@huawei.com>
 <20150205072125.GY13046@secunet.com>
 <54EFD87A.5080907@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<yangyingliang@huawei.com>, <hannes@redhat.com>
To: shengyong <shengyong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60193 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710AbbC3KcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 06:32:19 -0400
Content-Disposition: inline
In-Reply-To: <54EFD87A.5080907@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 10:37:46AM +0800, shengyong wrote:
>=20
>=20
> =E5=9C=A8 2015/2/5 15:21, Steffen Klassert =E5=86=99=E9=81=93:
> > On Wed, Feb 04, 2015 at 09:59:54AM +0800, shengyong wrote:
> >>
> >> Sorry, the later. I test it on 3.10-stable. It can fix this proble=
m. So maybe this is a bug?
> >=20
> > Yes, it's a bug.
> >=20
> >> And the 3 approaches (different flags are used: RTF_LOCAL, IFF_LOO=
PBACK and RTF_CACHE) in
> >> these mails can fix the expire of local address. I'm confused abou=
t these flags:
> >> * RTF_LOCAL: the entries of local address, like address binded to =
the native NIC
> >> * RTF_CACHE: all cached entries
> >> * IFF_LOOPBACK: this is a device-related flag, which has the same =
meaning as RTF_LOCAL
> >>
> >> Am I right? If so, I think RTF_LOCAL is appropriate, because we ju=
st want entries of local
> >> addresses to be not expired and we don't care other entries (I thi=
nk if they get expired,
> >> a neigh discovery could find them back).
> >=20
> > It is not the address that expires, it is the learned PMTU value th=
at
> > expires. If we delete an uncached route, nothing will bring it back
> > unless you readd it manually.
> >=20
> > We need to ensure that all routes that can learn something what
> > expires are cached. This means that we clone the inserted route
> > when it is used for the first time. The learned values are stored
> > at this cloned route. If the learned value expires, the clone is
> > deleted. The original route remains in the fib tree and can be
> > still looked up.
> >=20
> > The problem is, that we currently don't cache/clone host routes.
> > So if a host route learns something that expires, the original
> > route is removed from the fib tree and we loose connectivity
> > to that host. We don't cache host routes because some of them
> > (the local ones) are automatically added with metric 0.
> > If we try to cache such a route, the clone will be identical
> > to the original route and we fail to insert it to the fib tree.
> >=20
> > So we need to adjust the caching to all routes that actually can
> > learn something and leave out only those that can not.
> >=20
> > I'll send a patchset that should fix this at the beginning of the
> > next week.
> Hi, Steffen
> Is this patchset ready? It seems that I didn't find it in the mainlin=
g
> list. If it is ready, I can test it to see if it solves the problem I
> met :)

I finally end up with a patchset that passed all your testcases.
I'll send it in reply to this mail, please test it.

Thanks!
