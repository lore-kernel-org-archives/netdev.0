From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 4/6] myri10ge: limit the number of recoveries
Date: Tue, 08 May 2007 23:10:41 +0200
Message-ID: <4640E751.3040804@myri.com>
References: <463F9E9E.8000808@ens-lyon.org> <463F9F4E.4060706@myri.com> <464006F6.1040204@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1835 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1032202AbXEHVLE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 17:11:04 -0400
In-Reply-To: <464006F6.1040204@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Brice Goglin wrote:
>> Limit the number of recoveries from a NIC hw watchdog reset to
>> 1 by default.  This is tweakable via the myri10ge_reset_recover
>> tunable.
>
> NAK.  Tunables like this are generally (a) never touched by the vast
> majority of users, and (b) have useful values and purposes known only
> to Myri employees :)

Well, actually, it's kind of the opposite. Myri employees won't need to
tune this value since they will be able to replace the NIC with another
one immediately. The whole point of this tunable is to help end-users:
* The default value (set to 1) enables detection of defective NICs
immediately. These memory parity errors are expected to happen very
rarely (less than once per century per NIC). However, a defective NIC
(very rare, fortunately) can see such an error quite often, ie. every
few minutes under high load.
* An increased limit value will still allow people with mission critical
installations to crank up the tunable and recover an INTMAX number of
times while waiting for a downtime window to replace the NIC. The
performance won't be optimal, but at least, it will still work.

Should I resent the patch?

Thanks,
Brice

