From: Sanket Shah <sanketshah5124@gmail.com>
Subject: HFSC link sharing behavior related query
Date: Thu, 2 Jul 2009 16:53:40 +0530
Message-ID: <e54032850907020423q730dad3cm666594dfc130ffa9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:42291 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbZGBLXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 07:23:38 -0400
Received: by wf-out-1314.google.com with SMTP id 26so621307wfd.4
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2009 04:23:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
	We are doing experiments on hfsc in various network scenarios. Some
of the results are not as per our expectation/understanding of our
hfsc behavior.

-----------------------------------------------------------------------------------------------------------------------
	Scenario 1:

		1: (hfsc qdisc)
		|
		|
		1:1 (hfsc root class) (rt 0, ls 40, ul 40)
		|
	----------------------------------------------------------------
	|								|
	1:2 (rt 10, ls 1, ul 20)				1:3 (rt 30, ls 1, ul 40)
	|								|
	2: (sfq qdisc)						3: (sfq qdisc)

	In above scenario,
		1:2 and 1:3 both are doing http download and we are getting following results.

		1:2 - 10 kbps
		1:3 - 30 kbps		
			That is as per the expectation.

	After 5 minutes we are changing ls and ul of 1:1 from 40 to 100. (rt
0, ls 100, ul 100)
		
		For first 2 minutes after above change,

			1:2 - 20 kbps
			1:3 - 80 kbps
				In this case ul curve is getting violated for 2 mins.

		After 2 minutes,

			1:2 - 20 kbps
			1:3 - 50 kbps
				That is expected.

	Is it an expected behavior ?
	why ul curve got violated ?

-----------------------------------------------------------------------------------------------------------------------

	Scenario 2:

		1: (hfsc qdisc)
		|
		|
		1:1 (hfsc root class) (rt 0, ls 200, ul 200)
		|
-------------------------------------------------------------------------------------------------------------------------
|					|					|					|	
1:2 (rt 75, ls 32, ul 200)	1:3 (rt 25, ls 16, ul 200)	1:4(rt 50, ls 8,
ul 200)	1:5 (rt 25,ls 128,ul 200)
|					|					|					|
2: (sfq qdisc)			3: (sfq qdisc)			4:(sfq qdisc)			5: (sfq qdisc)

	In above scenario,
		1:2, 1:3, 1:4, 1:5 all are doing http download and we are expecting
following results,

		1:2 - 75 kbps
		1:3 - 25 kbps		
		1:4 - 50 kbps
		1:5 - 50 kbps (according to link sharing ratio, excess 25 kbps
bandwidth should remain with 1:5)

		But we are observing that 25 kbps excess bandwidth is floating
across 1:2,1:3 and 1:5 on about 4 to 5 minutes. We are also observing
few packet drops in 1:2 and 1:3. Is there any relation between link
sharing and packet drop ?

-----------------------------------------------------------------------------------------------------------------------

Regards,
Sanket Shah
