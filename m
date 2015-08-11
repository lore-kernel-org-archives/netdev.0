From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netconsole: Check for carrier before calling
 netpoll_send_udp()
Date: Mon, 10 Aug 2015 21:22:56 -0700 (PDT)
Message-ID: <20150810.212256.1658635789817625453.davem@davemloft.net>
References: <1439256746-7953-1-git-send-email-jmaxwell37@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jmaxwell@redhat.com
To: jmaxwell37@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439256746-7953-1-git-send-email-jmaxwell37@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Maxwell <jmaxwell37@gmail.com>
Date: Tue, 11 Aug 2015 11:32:26 +1000

> We have seen a few crashes recently where a NIC is getting
> reset for some reason and then the driver or another module calls
> printk() which invokes netconsole. Netconsole then calls the
> adapter specific poll routine via netpoll which crashes because 
> the adapter is resetting and its structures are being reinitialized.

This isn't a fix.

What if the carrier check passes, and then the chip reset starts on
another cpu?  You'll have the same problem.

I'm not applying this, sorry.
