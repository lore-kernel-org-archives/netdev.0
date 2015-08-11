From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netconsole: Check for carrier before calling
 netpoll_send_udp()
Date: Tue, 11 Aug 2015 10:25:21 -0700 (PDT)
Message-ID: <20150811.102521.448694660627631235.davem@davemloft.net>
References: <1439256746-7953-1-git-send-email-jmaxwell37@gmail.com>
	<20150810.212256.1658635789817625453.davem@davemloft.net>
	<CAGHK07DgBuVk==rJrc2gWa311DCMJK9NdDDk8OJAfRb=YLigBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jmaxwell@redhat.com
To: jmaxwell37@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGHK07DgBuVk==rJrc2gWa311DCMJK9NdDDk8OJAfRb=YLigBg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jonathan Maxwell <jmaxwell37@gmail.com>
Date: Tue, 11 Aug 2015 15:53:18 +1000

>> What if the carrier check passes, and then the chip reset starts on
>> another cpu?  You'll have the same problem.
> 
> Okay, let me see if I can come up with a better way to mitigate this.

I personally think that drivers need to synchronize such things
internally.  They are the only entity which knows when it's "OK"
to do whatever the netpoll method does, and they are also the only
entity which can properly synchronize such checks.
