From: "Gao Feng" <gfree.wind@vip.163.com>
Subject: RE: [PATCH net v3] driver: veth: Fix one possbile memleak when fail to register_netdevice
Date: Tue, 2 May 2017 19:03:02 +0800
Message-ID: <000601d2c333$abb526d0$031f7470$@vip.163.com>
References: <1493437911-27167-1-git-send-email-gfree.wind@foxmail.com> <CADvbK_cEHXTSXx5Qa17TfeUXnYiBq8ptR+=5e-fbzPF0r4DNhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: "'davem'" <davem@davemloft.net>, <jarod@redhat.com>,
        "'Stephen Hemminger'" <stephen@networkplumber.org>,
        <dsa@cumulusnetworks.com>, "'network dev'" <netdev@vger.kernel.org>
To: "'Xin Long'" <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-177180.vip.163.com ([123.58.177.180]:35455 "EHLO
        mail-177180.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750997AbdEBLDP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 07:03:15 -0400
In-Reply-To: <CADvbK_cEHXTSXx5Qa17TfeUXnYiBq8ptR+=5e-fbzPF0r4DNhQ@mail.gmail.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Xin Long [mailto:lucien.xin@gmail.com]
> Sent: Tuesday, May 2, 2017 3:56 PM
> On Sat, Apr 29, 2017 at 11:51 AM,  <gfree.wind@foxmail.com> wrote:
> > From: Gao Feng <gfree.wind@foxmail.com>
[...]
> > -static void veth_dev_free(struct net_device *dev)
> > +static void veth_destructor_free(struct net_device *dev)
> >  {
> >         free_percpu(dev->vstats);
> > +}
> not sure why you needed to add this function.
> to use free_percpu() directly may be clearer.

Because both of ndo_uninit and destructor need to perform same free statements.
It is good at maintain the codes with the common function.
> 
> > +
> > +static void veth_dev_uninit(struct net_device *dev) {
> call free_percpu() here, no need to check dev->reg_state.
> free_percpu will just return if dev->vstats is NULL.

It would break the original design if don't check the reg_state.
The original logic is that free the resources in the destructor, not in ndo_init.

BTW, because I send multiple patches too fast today, the email server blocks my account.
So I have to reply you with a different email account. Sorry.

Best Regards
Feng

> 
[...]
