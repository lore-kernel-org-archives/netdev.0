From: Paolo Valente <paolo.valente@unimore.it>
Subject: Re: [RFC PATCH net-next] qfq: handle the case that front slot is empty
Date: Sun, 28 Oct 2012 17:07:13 +0100
Message-ID: <AA223730-8F96-4265-84F5-6D68E54E4128@unimore.it>
References: <20121026165115.GA16947@paolo-ThinkPad-W520> <1351428300.15482.2.camel@cr0>
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Fabio Checconi <fchecconi@gmail.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spostino.sms.unimo.it ([155.185.44.3]:41979 "EHLO
	spostino.sms.unimo.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752239Ab2J1QHV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 12:07:21 -0400
In-Reply-To: <1351428300.15482.2.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Il giorno 28/ott/2012, alle ore 13:45, Cong Wang ha scritto:

> On Fri, 2012-10-26 at 18:51 +0200, Paolo Valente wrote:
>> Here is a possible patch. Could you please give me a feedback?
>> 
>> If this patch actually works, there are some issues related to it that I would
>> like to point out after your (and/or anyone else's) tests.
> 
> With this patch applied, I can't reproduce the crash any more.
Thank you for the test.
> 
> And the following messages appear in the log:
> 
> [  430.956400] qfq: increasing class max_pkt_size from 1514 to 26130
> [  430.981887] qfq: increasing class max_pkt_size from 26130 to 31922
> [  431.011844] qfq: increasing class max_pkt_size from 1514 to 2962
> [  431.060129] qfq: increasing class max_pkt_size from 31922 to 46402
> [  431.096241] qfq: increasing class max_pkt_size from 2962 to 4410
> [  431.123689] qfq: increasing class max_pkt_size from 4410 to 18890
> [  431.134624] qfq: increasing class max_pkt_size from 18890 to 20338
> [  431.149573] qfq: increasing class max_pkt_size from 20338 to 39162
> [  431.328157] qfq: increasing class max_pkt_size from 46402 to 56538
> [  431.339731] qfq: increasing class max_pkt_size from 56538 to 65226
> [  431.363699] qfq: increasing class max_pkt_size from 39162 to 44954
> [  431.376303] qfq: increasing class max_pkt_size from 44954 to 46402
> [  431.482082] qfq: increasing class max_pkt_size from 46402 to 62330
> [  431.520339] qfq: increasing class max_pkt_size from 62330 to 65226
> 
> 
WIth each of these messages, qfq now informs the user that he/she has chosen a too low max_pkt_size with respect to the actual size of the last-arrived packet, and that the max_pkt_size has been increased automatically to handle this larger packet correctly. In the log that you report, the large packets that cause qfq to increase the max_pkt_size are due to TSO/GSO.

Any feedback about these notifications is welcome. Meanwhile I will prepare a description of the patch and of the limitations it imposes.