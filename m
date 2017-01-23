From: Joel Cunningham <joel.cunningham@me.com>
Subject: sk_buff and reference counting netdev pointers
Date: Mon, 23 Jan 2017 16:37:06 -0600
Message-ID: <E593AEBC-5FD1-4CEF-A119-2C032DB574FC@me.com>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pv38p43im-ztdg05071201.me.com ([17.133.183.8]:42535 "EHLO
        pv38p43im-ztdg05071201.me.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751757AbdAWXh0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 18:37:26 -0500
Received: from process-dkim-sign-daemon.pv38p43im-ztdg05071201.me.com by
 pv38p43im-ztdg05071201.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OK900M007X6V200@pv38p43im-ztdg05071201.me.com> for
 netdev@vger.kernel.org; Mon, 23 Jan 2017 22:37:09 +0000 (GMT)
Received: from [192.168.1.9]
 (75-130-6-224.dhcp.ftwo.tx.charter.com [75.130.6.224])
 by pv38p43im-ztdg05071201.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 with ESMTPSA id <0OK900HFQ85VYK50@pv38p43im-ztdg05071201.me.com> for
 netdev@vger.kernel.org; Mon, 23 Jan 2017 22:37:09 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I=E2=80=99m working on a research effort to understand the =
synchronization mechanisms for accessing and modifying a struct =
net_device object.  One area that isn=E2=80=99t clear is the net device =
pointer (dev) stored in a struct sk_buff.  =46rom my investigation, the =
pointer appears to be assigned without increasing the struct =
net_device=E2=80=99s reference count (example __netdev_alloc_skb =
doesn=E2=80=99t call dev_hold) and also when the sk_buff is freed =
(kfree_skb) no call to dev_put() is made.  This seems to leave a =
possibility of an skb referencing a stale net device unless something is =
cleaning up all the skbs during unregister_netdevice() (which waits for =
all outstanding references to be released).  Any insight in =
understanding how this is working would be appreciated!

Joel=
