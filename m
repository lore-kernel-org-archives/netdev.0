From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH net v3] driver: veth: Fix one possbile memleak when fail to register_netdevice
Date: Wed, 3 May 2017 21:17:14 +0800
Message-ID: <002101d2c40f$958a7b80$c09f7280$@foxmail.com>
References: <1493437911-27167-1-git-send-email-gfree.wind@foxmail.com> <CADvbK_cEHXTSXx5Qa17TfeUXnYiBq8ptR+=5e-fbzPF0r4DNhQ@mail.gmail.com> <000601d2c333$abb526d0$031f7470$@vip.163.com> <CADvbK_cVS=M3tuz0QQT18D32UzLkdL0RMHuFxqcBgtfq_w7+9Q@mail.gmail.com> <000c01d2c3b2$0925e880$1b71b980$@foxmail.com> <CADvbK_c32g2t-Azgf10da8qke5B+wgG4dw3jLTE2L+R2qR3xPA@mail.gmail.com> <006101d2c3d7$bf814230$3e83c690$@foxmail.com> <CADvbK_dqU7wDQoU2nHBwPkQjzSuiVGXStYBD9iZSvz=j8SGt-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: "'Gao Feng'" <gfree.wind@vip.163.com>,
        "'davem'" <davem@davemloft.net>, <jarod@redhat.com>,
        "'Stephen Hemminger'" <stephen@networkplumber.org>,
        <dsa@cumulusnetworks.com>, "'network dev'" <netdev@vger.kernel.org>
To: "'Xin Long'" <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg303.qq.com ([184.105.206.26]:35595 "EHLO smtpbg303.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751176AbdECNRe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 09:17:34 -0400
In-Reply-To: <CADvbK_dqU7wDQoU2nHBwPkQjzSuiVGXStYBD9iZSvz=j8SGt-w@mail.gmail.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Xin Long [mailto:lucien.xin@gmail.com]
> Sent: Wednesday, May 3, 2017 7:26 PM
> On Wed, May 3, 2017 at 2:37 PM, Gao Feng <gfree.wind@foxmail.com> =
wrote:
> >> From: Xin Long [mailto:lucien.xin@gmail.com]
> >> Sent: Wednesday, May 3, 2017 1:38 PM
> >> On Wed, May 3, 2017 at 10:07 AM, Gao Feng <gfree.wind@foxmail.com>
> >> wrote:
> >> >> From: netdev-owner@vger.kernel.org
> >> >> [mailto:netdev-owner@vger.kernel.org]
> >> >> On Behalf Of Xin Long
> >> >> Sent: Wednesday, May 3, 2017 12:59 AM On Tue, May 2, 2017 at =
7:03
> >> >> PM, Gao Feng <gfree.wind@vip.163.com> wrote:
> >> >> >> From: Xin Long [mailto:lucien.xin@gmail.com]
> >> >> >> Sent: Tuesday, May 2, 2017 3:56 PM On Sat, Apr 29, 2017 at
> >> >> >> 11:51 AM,  <gfree.wind@foxmail.com> wrote:
> >> >> >> > From: Gao Feng <gfree.wind@foxmail.com>
> > [...]
> >> > The fix you mentioned change the original logic.
> >> > The dev->vstats is freed in advance in the ndo_uninit, not =
destructor.
> >> > It may break the backward.
> >> Sorry, I didn't get your "backward"
> >> I can't see there will be any problem caused by it.
> >> can you say this patch also break the 'backward' ?
> >> https://patchwork.ozlabs.org/patch/748964/
> >>
> >> It's really weird to do dev->reg_state check in ndo_unint ndo_unint
> >> is supposed to free the memory alloced in ndo_init.
> >>
> >
> > I am not sure if it would break the backward, so I said it MAY =
break.
> > I assumed there may be someone would access the dev->vstats after
> > ndo_uninit, because current veth driver free the mem in the =
destructor.
> > I selected this approach because I don't want to bring new bugs =
during fix
> bug.
> >
> > If you're sure it is safe to free dev->vstats in ndo_uninit, I would =
like to
> update it.
> yes, stats are accessed in .ndo_start_xmit waited by synchronize_net() =
and
> .ndo_get_stats64 protected by rtnl_lock().

Thanks, I would update the series later with your advice.
I need to wait for a while to collect more comments.
=20
> >
> > BTW there are too many drivers which have possible memleak.
> > You could find the list by
> https://www.mail-archive.com/netdev@vger.kernel.org/msg166629.html.
> ah, cool.
> I'm not sure about other dev's stuff, have to check them for sure =
later.

Expect and thanks your reviews:)

Best Regards
Feng

>=20
> >
> > Some drivers allocate the resources in ndo_init, free some in =
ndo_uninit and
> free left in destructor.
> > I think there are some reasons.
> > We could not move all free in the ndo_uninit from destructor. What's =
your
> opinion?
> >
> > Best Regards
> > Feng
> >
> >
> >
