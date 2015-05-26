From: Cong Wang <cwang@twopensource.com>
Subject: Re: tc drop stats different between bond and slave interfaces
Date: Tue, 26 May 2015 10:10:24 -0700
Message-ID: <CAHA+R7MnHDVayA3MqpyR7J09tGNdh=OMmJAZG-0+rRhsmCNTNA@mail.gmail.com>
References: <616929303.117745.1432618508227.JavaMail.open-xchange@oxuslxltgw05.lxa.perfora.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35909 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbbEZRK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 13:10:26 -0400
Received: by wizk4 with SMTP id k4so84634975wiz.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 10:10:24 -0700 (PDT)
In-Reply-To: <616929303.117745.1432618508227.JavaMail.open-xchange@oxuslxltgw05.lxa.perfora.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 25, 2015 at 10:35 PM, jsullivan@opensourcedevel.com
<jsullivan@opensourcedevel.com> wrote:
>
> I was also surprised to see that, although we are using a prio qdisc on the
> bond, the physical interface is showing pfifo_fast.
>
[...]
>
> So why the difference and why the pfifo_fast qdiscs on the physical interfaces?

Qdisc is not aware of the network interface you attach it to, so it doesn't know
whether it is bond or whatever stacked interface, the qdisc you add to bonding
master has no idea about its slaves.

For pfifo_fast, it is the default qdisc when you install mq on root, it is where
mq actually holds the packets.

Hope this helps.
