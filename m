From: John Greene <jogreene@redhat.com>
Subject: Re: [RFT PATCH] 8139cp: properly support change of MTU values [v2]
Date: Tue, 04 Dec 2012 14:04:04 -0500
Message-ID: <50BE4924.40904@redhat.com>
References: <1354551573-23721-1-git-send-email-jogreene@redhat.com>  <20121203.135200.1242505353532930826.davem@davemloft.net>  <20121203204608.GA9815@electric-eye.fr.zoreil.com> <1354635895.24281.144.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31258 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751090Ab2LDTEU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 14:04:20 -0500
In-Reply-To: <1354635895.24281.144.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2012 10:44 AM, David Woodhouse wrote:
> On Mon, 2012-12-03 at 21:46 +0100, Francois Romieu wrote:
>> David Miller <davem@davemloft.net> :
>> [...]
>>> I've applied this to net-next, if it triggers any problems we have
>>> some time to work it out before 3.8 is released.
>>
>> I have bounced the messages to David Woodhouse since he authored the
>> last 8139cp changes in net-next and owns the hardware to notice
>> regressions.
>
> Thanks.
>
> This almost works. The patch itself is fine, but the device can't
> receive packets larger than 2266 bytes (ping -s 2238). After that, I get
> rx_fifo errors. I think the RX FIFO is only 2KiB on the 8139cp, isn't
> it? So after that it's dependent on how fast it can shovel it out across
> the PCI bus. Which is "not fast" in this case.
>
> Transmit appears to be fine.
>
Checked the datasheet (admittedly old v1.5 12/6/2001): yes FIFOs are 2k 
on both Rx and Tx.  I need to check this on the emulator again, but it 
didn't fail with pings up to nearly 9000 bytes, apparently a difference 
of real vs. virtual hardware (perhaps an interesting science experiment 
to adjust MTU to what the underlying hardware does, but not today ;)

Still, this does fix reported problem that driver could be set to huge 
MTU erroneously, and now rejects really weird values as it should.

Thanks for the test, David.

Anything to add/subtract?

Francois: I noted your follow on patch, find merit in it as well.  I 
need to digest it more fully and expect it should be a follow up to this 
barring any other issues from me: appreciate your help also!



-- 
John Greene
jogreene@redhat.com
