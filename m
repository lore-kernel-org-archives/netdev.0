From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/5] bonding: Initialize the ALB work queue for lb mode
 only.
Date: Mon, 31 Mar 2014 09:40:40 -0700
Message-ID: <1396284040.29410.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1396070946-17650-1-git-send-email-maheshb@google.com>
	 <1396280940.29410.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5848.1396283241@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:37024 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbaCaQkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 12:40:42 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so8505428pad.28
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 09:40:41 -0700 (PDT)
In-Reply-To: <5848.1396283241@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-31 at 09:27 -0700, Jay Vosburgh wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> >On Fri, 2014-03-28 at 22:29 -0700, Mahesh Bandewar wrote:
> >> micro change to initialize / cancel the ALB work queue only
> >> if the mode selected is ALB or TLB.
> >> 
> >> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> >> ---
> >
> >Can the mode of a bonding device be dynamically changed ?
> 
> 	No.  The mode can only be changed when there are no slaves in
> the bond, and the bond is administratively down.

I don't see why this patch is needed.

What about mii_work, arp_work ?

There is no cost calling INIT_DELAYED_WORK(&bond->alb_work,
bond_alb_monitor) and cancel_delayed_work_sync(&bond->alb_work)
