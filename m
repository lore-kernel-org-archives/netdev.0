From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] bonding: fix packets_per_slave showing
Date: Thu, 05 Dec 2013 12:35:36 +0100
Message-ID: <52A06508.9050001@redhat.com>
References: <1386239818-7408-1-git-send-email-nikolay@redhat.com> <20131205110843.GD23210@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64113 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932086Ab3LELj7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 06:39:59 -0500
In-Reply-To: <20131205110843.GD23210@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2013 12:08 PM, Veaceslav Falico wrote:
> On Thu, Dec 05, 2013 at 11:36:58AM +0100, Nikolay Aleksandrov wrote:
>> There's an issue when showing the value of packets_per_slave due to
>> using signed integer. The value may be < 0 and thus not put through
>> reciprocal_value() before showing. This patch makes it use unsigned
>> integer when showing it.
> 
> I was already checking my basic algebra knowledge here,
> reciprocal_value(reciprocal_value(0..USHRT_MAX)) can become negative?!? :)
> 
> If anyone's also wondering...
> 
> packets_per_slave is reciprocal_value(0..USHRT_MAX), and thus can indeed be
> negative, and then the code
> 
>     if (packets_per_slave > 1)
>         packets_per_slave = reciprocal_value(packets_per_slave);
> 
> would fail to recognise that it's a reciprocal_divide() value, and not a
> standard 0/1 option (in bond_rr_gen_slave_id() we verify it via a switch,
> so we're safe there) - and thus output nonsense.
> 
> Acked-by: Veaceslav Falico <vfalico@redhat.com>
> 
Thanks for the review. Indeed, I should've made it unsigned from the beginning
but thought to be consistent with the other options (just don't ask why :) ).
Anyhow, once net-next opens up I can convert it to unsigned completely as it's
supposed to be.

Cheers,
 Nik
