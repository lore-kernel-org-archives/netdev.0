From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH nf v3 1/1] netfilter: snmp: Fix one possible panic when snmp_trap_helper fail to register
Date: Fri, 24 Mar 2017 20:42:07 +0800
Message-ID: <000401d2a49c$0d094350$271bc9f0$@foxmail.com>
References: <1490055749-52357-1-git-send-email-fgao@ikuai8.com> <20170324122130.GA3080@salvia> <20170324122301.GA3160@salvia>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="gb2312"
Content-Transfer-Encoding: quoted-printable
Cc: <davem@davemloft.net>, <jolsa@redhat.com>,
        <netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <gfree.wind@gmail.com>
To: "'Pablo Neira Ayuso'" <pablo@netfilter.org>, <fgao@ikuai8.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg62.qq.com ([103.7.29.139]:27593 "EHLO smtpbg64.qq.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751492AbdCXMue (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 08:50:34 -0400
In-Reply-To: <20170324122301.GA3160@salvia>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

> -----Original Message-----
> From: netfilter-devel-owner@vger.kernel.org
> [mailto:netfilter-devel-owner@vger.kernel.org] On Behalf Of Pablo =
Neira
Ayuso
> Sent: Friday, March 24, 2017 8:23 PM
> To: fgao@ikuai8.com
> Cc: davem@davemloft.net; jolsa@redhat.com;
netfilter-devel@vger.kernel.org;
> netdev@vger.kernel.org; gfree.wind@gmail.com
> Subject: Re: [PATCH nf v3 1/1] netfilter: snmp: Fix one possible panic
when
> snmp_trap_helper fail to register
>=20
> On Fri, Mar 24, 2017 at 01:21:30PM +0100, Pablo Neira Ayuso wrote:
> > On Tue, Mar 21, 2017 at 08:22:29AM +0800, fgao@ikuai8.com wrote:
> > > From: Gao Feng <fgao@ikuai8.com>
> > >
> > > In the commit 93557f53e1fb ("netfilter: nf_conntrack: nf_conntrack
> > > snmp helper"), the snmp_helper is replaced by nf_nat_snmp_hook. So
> > > the snmp_helper is never registered. But it still tries to
> > > unregister the snmp_helper, it could cause the panic.
> >
> > This patch looks correct to me.
> >
> > But probably for some reason I don't manage to trigger, how do you
> > reproduce this?
>=20
> I'm refering to the panic.
[=B8=DF=B7=E5]=20
It is got by reviewing the codes.
When nf_conntrack_helper_unregister(&snmp_helper), but snmp_helper =
didn't
register actually.
And snmp_helper. hnode is not initialized, it would trigger the issue =
when
hlist_del_rcu in nf_conntrack_helper_unregister.

Best Regards
Feng


> --
> To unsubscribe from this list: send the line "unsubscribe =
netfilter-devel"
in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
