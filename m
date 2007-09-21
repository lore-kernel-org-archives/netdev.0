From: jamal <hadi@cyberus.ca>
Subject: Re: [LARTC] ifb and ppp
Date: Fri, 21 Sep 2007 07:23:09 -0400
Message-ID: <1190373789.4261.16.camel@localhost>
References: <200709191417.43768.mail@frithjof-hammer.de>
	 <46F25F9A.7010007@trash.net> <1190294388.4734.6.camel@localhost>
	 <200709201600.15202.mail@frithjof-hammer.de>  <46F2910E.9040900@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Frithjof Hammer <mail@frithjof-hammer.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:13557 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755063AbXIULXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 07:23:13 -0400
Received: by an-out-0708.google.com with SMTP id d31so125229and
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 04:23:12 -0700 (PDT)
In-Reply-To: <46F2910E.9040900@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-20-09 at 17:26 +0200, Patrick McHardy wrote:
>  I don't see a good solution for this that
> allows to keep the iptables rules, I'd suggest to switch to ematches.

One approach could be to use ipt action:

-------------------
tc filter add dev ppp0 parent ffff: protocol ip u32 match u32/ematch
some match flowid 1:1 action ipt -j mark --set-mark 1
..
...
....
iptables here to use the marks ...
----------------

cheers,
jamal

