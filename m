From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: rtnl_newlink() cleanup on namespace change
Date: Tue, 10 Mar 2015 16:44:06 -0700
Message-ID: <CAM_iQpXNp4+1D454yrwJyER50gKC3N1CtDffEExDYiGCENTiFQ@mail.gmail.com>
References: <20150310.184347.1581730121744725414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35723 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbbCJXoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 19:44:07 -0400
Received: by pdbfp1 with SMTP id fp1so6174781pdb.2
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 16:44:06 -0700 (PDT)
In-Reply-To: <20150310.184347.1581730121744725414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2015 at 3:43 PM, David Miller <davem@davemloft.net> wrote:
>
> Cong, I was reviewing commit 7afb8886a05be68e376655539a064ec672de8a8e
> ("rtnetlink: call ->dellink on failure when ->newlink exists") during
> a stable backport and I noticed that the function, after the change
> you made, subsequently goes:
>
>                 if (link_net) {
>                         err = dev_change_net_namespace(dev, dest_net, ifname);
>                         if (err < 0)
>                                 unregister_netdevice(dev);
>                 }
>
> Isn't the potential ->dellink() unwinding necessary in this path too?
>

Right, I wasn't aware of the link_net change.
Do you want me to send a fix?

Thanks.
