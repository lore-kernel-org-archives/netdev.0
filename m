From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v8 net-next 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Mon, 19 Oct 2015 18:35:56 +0200
Message-ID: <20151019163556.GK2288@nanopsycho.orion>
References: <1412469901-27451-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:32985 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461AbbJSQf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 12:35:59 -0400
Received: by wijp11 with SMTP id p11so14785438wij.0
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 09:35:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1412469901-27451-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Oct 05, 2014 at 02:45:01AM CEST, maheshb@google.com wrote:
>Earlier change to use usable slave array for TLB mode had an additional
>performance advantage. So extending the same logic to all other modes
>that use xmit-hash for slave selection (viz 802.3AD, and XOR modes).
>Also consolidating this with the earlier TLB change.
>
>The main idea is to build the usable slaves array in the control path
>and use that array for slave selection during xmit operation.
>
>Measured performance in a setup with a bond of 4x1G NICs with 200
>instances of netperf for the modes involved (3ad, xor, tlb)
>cmd: netperf -t TCP_RR -H <TargetHost> -l 60 -s 5
>
>Mode        TPS-Before   TPS-After
>
>802.3ad   : 468,694      493,101
>TLB (lb=0): 392,583      392,965
>XOR       : 475,696      484,517

Looking over bonding code now and came across this commit. It gave me a
little headache. Why don't you guys just use team instead of doing
bonding megapatches like this? This is making bonding code even more
complicated (screwed-up) :/ I don't understand.
