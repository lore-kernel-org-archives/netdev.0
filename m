From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'adm8211' branch of wireless-2.6
Date: Sat, 15 Sep 2007 20:56:19 -0400
Message-ID: <46EC7F33.2050206@garzik.org>
References: <20070915132220.GE6060@tuxdriver.com> <46EC4F78.4050700@garzik.org> <200709152017.02646.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Michael Wu <flamingice@sourmilk.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55948 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752278AbXIPA4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Sep 2007 20:56:25 -0400
In-Reply-To: <200709152017.02646.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
> On Saturday 15 September 2007 17:32, Jeff Garzik wrote:
>> Review summary:  many minor issues, only one major one:  irq handler loop
>>
> CCing me would help.

Sorry.  I just hit 'reply to all'...  apparently you were not CC'd on 
the submission.


>>> +	if (flags & IFF_PROMISC)
>>> +		dev->flags |= IEEE80211_HW_RX_INCLUDES_FCS;
>>> +	else
>>> +		dev->flags &= ~IEEE80211_HW_RX_INCLUDES_FCS;
>> why does promisc dictate inclusion of FCS?
>>
> Because that's the way the hardware works.

Why not always include it, regardless of promisc?


>>> +	} while (count++ < 20);
>> NAK -- talk about back to the past.
>>
>> It's bogus to loop in the interrupt handler, then loop again in both RX
>> and TX paths.  You are getting close to reinventing the wheel here.
>>
>> Use NAPI rather than doing such a loop.
>>
> This is old interrupt handler code from Jouni's original driver. I never 
> bothered to replace it with the simpler designs used in newer drivers I've 
> worked on.
> 
> Also - mac80211 drivers have no access to NAPI.

Not true as of net-2.6.24.



>>> +/* CSR (Host Control and Status Registers) */
>>> +struct adm8211_csr {
>> [snip]
>>> +} __attribute__ ((packed));
>> attributed(packed) is unneccesary here, and its use results in
>> sub-optimal code
>>
> How? Doesn't this just turn into a bunch of offsets?

It depends on how its used in the code.


>> enums are preferred.  they do not disappear at the cpp stage, and confer
>> type information.
>>
> I'd rather not.

Elaboration?

Remember this code is not just for you, but for all people working with 
the code.  It makes debugging (and sometimes tracebacks) much more 
readable, since it hasn't been eaten by cpp.

Thanks,

	Jeff


