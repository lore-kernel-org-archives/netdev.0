From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 16:45:24 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F143B177@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: johnpol@2ka.mipt.ru, kelly@au1.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:25098 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S965004AbWD1Xpx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 19:45:53 -0400
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>, rusty@rustcorp.com.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Sat, 29 Apr 2006 08:04:04 +1000
> 
>> You're still thinking you can bypass classifiers for established
>> sockets, but I really don't think you can.  I think the simplest
>> solution is to effectively remove from (or flag) the established &
>> listening hashes anything which could be effected by classifiers, so
>> those packets get send through the default channel.
> 
> OK, when rules are installed, the socket channel mappings are
> flushed.  This is your idea right?

You mean when new rules are installed that would conflict with
an existing mapping, right?

Bumping every connection out of vj-channel mode whenever any new
rule was installed would be very counter-productive.

Ultimately, you only want a direct-to-user vj-channel when all
packets assigned to it would be passed by netchannels, and maybe
increment a single packet counter. Checking a single QoS rate
limiter may be possible too, but if there are more complex
rules then the channel has to be kept in kernel because it
wouldn't make sense to trust user-mode code to apply the
netchannel rules reliably.

