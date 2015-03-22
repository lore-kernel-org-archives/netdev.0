From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next v2 0/4] bonding work-queues, try_rtnl() & notifications
Date: Sat, 21 Mar 2015 19:23:51 -0700
Message-ID: <CANP3RGeVhFMSvToY7nTu06+eYyscJyHS=uEswnH9Wh=UNfMscQ@mail.gmail.com>
References: <1426916355-18289-1-git-send-email-maheshb@google.com>
	<20150321.181700.1162404019090592599.davem@davemloft.net>
	<CAF2d9jhMz4Y1ye_ofkgvXyxUJEpNnLrFjMJhHQXKbf6MSS-OVg@mail.gmail.com>
	<20150321.221631.908834228517236497.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Linux NetDev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:36725 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476AbbCVCXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 22:23:52 -0400
Received: by qgez102 with SMTP id z102so33221026qge.3
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2015 19:23:52 -0700 (PDT)
In-Reply-To: <20150321.221631.908834228517236497.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Someone has to do the work, and if the rtnl-owner does it we do not
> incur all of the overhead the resubmission entails.

Are you suggesting:
- adding a global queue of (function pointer, long arg)
- changing rtnl_unlock to iterate through the queue calling
function(arg) before it actually releases the rtnl lock
?

(life might be easier if you can actually pass 2 args, but that's a
minor detail)

I guess at that point you could even have a generic method

void asynch_call_under_rtnl(function, arg) {
  rtnl_callback_add_to_queue(function,arg)
  if (rtnl_try_lock())
    rtnl_unlock();
}

- Maciej
