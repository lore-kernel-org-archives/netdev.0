From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPROUTE 01/05]: Use tc_calc_xmittime where appropriate
Date: Tue, 16 Jan 2007 11:19:34 +0100
Message-ID: <45ACA6B6.1090902@trash.net>
References: <20070116085611.GA1003@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47400 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbXAPKTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 05:19:38 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20070116085611.GA1003@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On 10-01-2007 11:01, Patrick McHardy wrote:
> 
>>[IPROUTE]: Use tc_calc_xmittime where appropriate
>>
>>diff --git a/tc/tc_red.c b/tc/tc_red.c
>>index 385e7af..8f9bde0 100644
>>--- a/tc/tc_red.c
>>+++ b/tc/tc_red.c
>>@@ -71,7 +71,7 @@ int tc_red_eval_ewma(unsigned qmin, unsi
>> 
>> int tc_red_eval_idle_damping(int Wlog, unsigned avpkt, unsigned bps, __u8 *sbuf)
>> {
>>-	double xmit_time = tc_core_usec2tick(1000000*(double)avpkt/bps);
>>+	double xmit_time = tc_calc_xmittime(bps, avpkt);
> 
> 
> Return value changed to unsigned here.
> (According to iproute2-2.6.19-061214.) 


Right, this changes it from long (tc_core_usec2tick) to unsigned
int. It doesn't make any difference though, with 32 bit we can
represent transmission times up to ~1 hour (for a single packet),
which is far more than needed.

