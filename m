From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/1] myri10ge: limit the number of recoveries
Date: Mon, 04 Jun 2007 19:07:04 +0200
Message-ID: <466446B8.4000800@myri.com>
References: <465DCCB4.5040404@myri.com> <465DCD16.8050907@myri.com> <4662E481.4030508@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1837 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756119AbXFDRHG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 13:07:06 -0400
Received: from [172.31.134.203] (brice-ovpn.sw.myri.com [172.31.134.203])
	by myri.com (8.13.7+Sun/8.13.7) with ESMTP id l54H749Q001005
	for <netdev@vger.kernel.org>; Mon, 4 Jun 2007 10:07:04 -0700 (PDT)
In-Reply-To: <4662E481.4030508@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Brice Goglin wrote:
>> Limit the number of recoveries from a NIC hw watchdog reset to 1 by
>> default.
>> It enables detection of defective NICs immediately since these memory
>> parity
>> errors are expected to happen very rarely (less than once per
>> century*NIC).
>> However, a defective NIC (very rare, fortunately) can see such an error
>> quite often, ie. every few minutes under high load.
>>
>> Make the limit tunable to allow people with mission critical
>> installations
>> to crank up the tunable and recover an INTMAX number of times while
>> waiting
>> for a downtime window to replace the NIC. The performance won't be
>> optimal,
>> but at least, it will still work.
>>
>> Signed-off-by: Brice Goglin <brice@myri.com>
>> ---
>>  drivers/net/myri10ge/myri10ge.c |   15 +++++++++++++--
>>  1 file changed, 13 insertions(+), 2 deletions(-)
>
> NAK.

Ok...
Then please apply the following patch which limits the number of
recovery to 1 without making it tunable. It will at least enable
detection of bad NICs.

Brice


