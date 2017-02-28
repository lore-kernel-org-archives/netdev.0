From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [drivers/net/vxlan]Why rcu_read_lock is not obtained before
 rculist travelling
Date: Tue, 28 Feb 2017 13:29:17 -0800
Message-ID: <CAM_iQpUp+nmLW2i3Gm2YQnq+_EA5ozvgO33fG6k=x+kQx9kt_Q@mail.gmail.com>
References: <199cc09e.de3a.15a8508c1f7.Coremail.yanxb123@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?UTF-8?B?6aKc5bCP5rOi?= <yanxb123@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:33716 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751829AbdB1ViD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 16:38:03 -0500
Received: by mail-wm0-f41.google.com with SMTP id i17so5139629wmf.0
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 13:36:42 -0800 (PST)
In-Reply-To: <199cc09e.de3a.15a8508c1f7.Coremail.yanxb123@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2017 at 6:03 AM, =E9=A2=9C=E5=B0=8F=E6=B3=A2 <yanxb123@163.=
com> wrote:
> But I don=E2=80=99t find any rcu_read_lock invoked before travelling fdb_=
head list.  In vxlan_xmit and vxlan_snoop function, vxlan_find_mac function=
 is called to search the vxlan_fdb of the dst_mac or src_mac. Then informat=
ion in vxlan_fdb  is used for further process.  But as no rcu_read_lock is =
obtained before the list travelling, I am wondering if it is possible that =
vxlan_fdb is freed when it is being used.
>

In both RX and TX paths, rcu read lock is acquired by upper layer.
Check __dev_queue_xmit() and process_backlog().
