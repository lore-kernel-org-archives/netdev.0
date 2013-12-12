From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: Re: [patch net-next v2] ipv6: log autoconfiguration failures
Date: Thu, 12 Dec 2013 12:28:16 +0100
Message-ID: <52A99DD0.9030007@redhat.com>
References: <1386762314-5149-1-git-send-email-dvlasenk@redhat.com> <20131211192138.GB4675@order.stressinduktion.org> <20131211.155452.558417595732985707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	jpirko@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28206 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751436Ab3LLL25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 06:28:57 -0500
In-Reply-To: <20131211.155452.558417595732985707.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2013 09:54 PM, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 11 Dec 2013 20:21:38 +0100
> 
>> On Wed, Dec 11, 2013 at 12:45:14PM +0100, Denys Vlasenko wrote:
>>> If ipv6 auto-configuration does not work, currently it's hard
>>> to track what's going on. This change adds log messages
>>> (at debug level) on every code path where ipv6 autoconf fails.
>>>
>>> v2: fixed indentation in multi-line log output statements.
>>
>> Have you seen lots of those problems? Some of those seem like very
>> serious problems and maybe could also deserve a pr_warn or pr_err.
>>
>> I hope these are one-time errors, so I don't think counters would
>> be helpful.
> 
> I still think that statitics would better serve this issue.
> 
> You can make them part of the per-inet6_dev MIB, and therefore
> implicitly letting the admin know what interface the events
> occurred on.

Putting myself in admin's boots...

Admins want to know why ipv6 autoconf didn't work, not so much
how many times it didn't work. This requires a text message.

> For one thing, the event would always be counted, whereas with
> pr_debug() someone has to turn on dynamic debugging in order
> to see the message.

Point taken wrt pr_debug being too gentle.
I should have used pr_warn or at least pr_info...

-- 
vda
