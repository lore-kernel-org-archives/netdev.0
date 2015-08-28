From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net v2] bonding: fix bond_poll_controller bh_enable warning
Date: Fri, 28 Aug 2015 14:59:40 -0700
Message-ID: <69380EC5-CF63-48BE-AFCB-4F70E6869DFC@cumulusnetworks.com>
References: <658DEBCA-6BE2-4388-AFE8-58C6A71029AC@cumulusnetworks.com> <1440782540-7876-1-git-send-email-razor@blackwall.org> <20150828.141351.2056521281131696426.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, 13806511171@163.com,
	shemminger@linux-foundation.org, maheshb@google.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34045 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbbH1V7n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 17:59:43 -0400
Received: by pabzx8 with SMTP id zx8so75021760pab.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 14:59:43 -0700 (PDT)
In-Reply-To: <20150828.141351.2056521281131696426.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Aug 28, 2015, at 2:13 PM, David Miller <davem@davemloft.net> wrote:
> 
> From: Nikolay Aleksandrov <razor@blackwall.org>
> Date: Fri, 28 Aug 2015 10:22:20 -0700
> 
>> The problem is rcu_read_unlock_bh() which triggers a warning when
>> irqs are disabled.  ndo_poll_controller can run with bh enabled,
>> disabled or irqs disabled so check if that is the case and acquire
>> rcu_read_lock_bh only when not running with disabled irqs.
> 
> I would say that having hard irqs disabled is a strict requirement, as
> per the debugging test in netpoll_send_skb_on_dev():
> 
> 	WARN_ON_ONCE(!irqs_disabled());
> 
> If you want to add the same check to netpoll_send_udp(), that's fine.
> 
> But what isn't fine is adding all of this conditional locking, we want
> ->poll_controller() implementations to be able to depend upon the IRQ
> environment they execute in, otherwise every single implementation
> might need to have ugly conditional locking as well.

Great, that is what I wanted to know because I got confused by some older
commits. This will simplify the fix and I will add the warn_on in netpoll_send_udp().
v3 coming up

Thank you,
 Nik