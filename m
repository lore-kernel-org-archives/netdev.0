From: Chris Metcalf <cmetcalf@ezchip.com>
Subject: Re: [PATCH v2] nohz: prevent tilegx network driver interrupts
Date: Fri, 10 Jul 2015 19:06:23 -0400
Message-ID: <55A04FEF.2000204@ezchip.com>
References: <55A0175E.2010200@ezchip.com>
 <1436557045-5392-1-git-send-email-cmetcalf@ezchip.com>
 <20150710224500.GA25028@jcartwri.amer.corp.natinst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Frederic Weisbecker <fweisbec@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Josh Cartwright <joshc@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0087.outbound.protection.outlook.com ([157.56.112.87]:22592
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751842AbbGJXGT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jul 2015 19:06:19 -0400
In-Reply-To: <20150710224500.GA25028@jcartwri.amer.corp.natinst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/10/2015 6:45 PM, Josh Cartwright wrote:
>> +static inline const struct cpumask *housekeeping_cpumask(void)
>> >+{
>> >+#ifdef CONFIG_NO_HZ_FULL
>> >+	if (tick_nohz_full_enabled())
>> >+		return housekeeping_mask;
>> >+#endif
> Just a small comment:
>
> We can take these checks out from under a #ifdef CONFIG_NO_HZ_FULL
> check, given that are stubbed tick_nohz_full_enabled() defined above.

True for the "if" clause, but the "housekeeping_mask" variable is only defined
under CONFIG_NO_HZ_FULL.

-- 
Chris Metcalf, EZChip Semiconductor
http://www.ezchip.com
