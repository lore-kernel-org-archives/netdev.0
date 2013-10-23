From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: BUG: scheduling while atomic
 dev_set_promiscuity->__dev_notify_flags
Date: Wed, 23 Oct 2013 03:53:56 +0000 (UTC)
Message-ID: <slrnl6ei2u.vgu.xiyou.wangcong@linux-6brj.site>
References: <CAMEtUuy91zYJ=bj1dzfdqE8kqZ3rE1RgdR-PZYekSUg8_xoTBw@mail.gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:54175 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754353Ab3JWDyS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 23:54:18 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VYpWS-0003yD-Uc
	for netdev@vger.kernel.org; Wed, 23 Oct 2013 05:54:16 +0200
Received: from c-67-169-68-218.hsd1.ca.comcast.net ([67.169.68.218])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 05:54:16 +0200
Received: from xiyou.wangcong by c-67-169-68-218.hsd1.ca.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 05:54:16 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Oct 2013 at 01:04 GMT, Alexei Starovoitov <ast@plumgrid.com> wrote:
>
> packet_notifier() does rcu_read_lock() before calling into packet_dev_mc() .
>
> Not sure how to fix it cleanly, other than disabling a notify here.
> Any suggestion?
>

Passing a gfp flag to rtmsg_ifinfo() seems a right fix for me, but I don't
know if there is other better way to fix it.
