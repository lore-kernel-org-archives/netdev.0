From: rapier <rapier@psc.edu>
Subject: size of data_segs_[in|out] and segs_[in|out]
Date: Mon, 8 Aug 2016 18:02:29 -0400
Message-ID: <797392fa-8d87-f45b-69b2-fdd096e1229c@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:48052 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750938AbcHHWrf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2016 18:47:35 -0400
Received: from iztli.psc.edu (iztli.psc.edu [128.182.160.106])
	(authenticated bits=0)
	by mailer1.psc.edu (8.13.8/8.13.8) with ESMTP id u78M2TNW027500
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 Aug 2016 18:02:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The instruments for data_segs_in, data_segs_out, segs_in, and segs_out 
(along with the corresponding tcpi_ variables) are currently defined as 
unsigned 32 bit ints. While this is in line with RFC4898 I'm thinking 
that for some flows this value might be too small.

For example, a 1GB sustained flow at 1500 bytes would exceed the max 
value inside of around 14.7 hours. Which seems like a long time but at 
higher rates, even with 9k packets, this could cause problems within 7.5 
hours or so (after ~36TB of data). While this is probably not an issue 
for a large number of people in the scientific community transferring 
data sets of this size is happening and likely to become far more common.

As such, would it be feasible to define these instruments as 64bit 
instead of 32bit? If so, a cursory look at the code seems to indicate 
that this would only require a change in the header files.

Chris
