From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB vs HFSC, HTB is highly inaccurate
Date: Mon, 9 Mar 2009 08:07:00 +0000
Message-ID: <20090309080700.GA4760@ff.dom.local>
References: <200903082045.39083.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:58877 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbZCIIHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 04:07:09 -0400
Received: by fxm24 with SMTP id 24so1124407fxm.37
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2009 01:07:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200903082045.39083.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08-03-2009 19:45, Denys Fedoryschenko wrote:
> Hi again
> 
> I test again HTB and HFSC, this time in very simple case.
> 
> Regarding HTB - i try without quantum, with different values, without and with 
> cburst (big and small), with HZ=1000 and default, hysteresis on and off - it 
> is almost same result. 
> 
> While i set limit at 57, it can reach 61. HFSC results is perfect.
> 
> Here is graph snapshopts.
> http://www.nuclearcat.com/netdev/htb-problem.png
> You can see points where HTB enabled. Other points if HFSC.

Very nice picture, but some tc snapshot stats for qdisc and classes
would be appreciated.

> 
> Scripts source is:
> 
> HTB http://www.nuclearcat.com/netdev/htb-script.txt

| echo "class add dev eth0.37 parent 1:1 classid 1:2 htb rate 40Mbit ceil 56Mbit burst 16000b cburst 16000b quantum 16000"
| echo "class add dev eth0.37 parent 1:1 classid 1:3 htb rate 26Mbit ceil 56Mbit burst 16000b cburst 16000b quantum 16000"

I guess you should try with rates 40/16 or 30/26 here.

BTW, it doesn't matter here, but for various reasons it's better to
add classes before filters pointing these classes.

> HFSC http://www.nuclearcat.com/netdev/hfsc-script.txt

This link doesn't work for me.

Jarek P.
