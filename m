From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net] mscan: zero accidentally copied register content
Date: Thu, 06 Oct 2011 16:01:45 +0200
Message-ID: <4E8DB4C9.30109@hartkopp.net>
References: <4E8C78E8.3010605@hartkopp.net> <20111005155127.GB13794@pengutronix.de> <4E8C8175.2040202@hartkopp.net> <4E8D528D.8020607@hartkopp.net> <4E8D7065.8040905@grandegger.com> <20111006092456.GB1974@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch@gmail.com>
To: Wolfram Sang <w.sang@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:34512 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753720Ab1JFOBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 10:01:53 -0400
In-Reply-To: <20111006092456.GB1974@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/11 11:24, Wolfram Sang wrote:

> 
>> Why do you want to change 16-bit accesses in general? They are faster
>> than two 8 bit accesses. 
> 
> Yup, was thinking the same.


Ah, i did not get this from your code example

	if (can_dlc & 1)
		*payload = in_be16() & mask;


which probably does the same as Wolfgangs more obvious suggestion

	if (frame->can_dlc & 1)
		frame->data[frame->can_dlc - 1] = in_8(data);


:-)

As my patch could be done without real testing, as i did not change the
register access and only fixed the result ...

	if (frame->can_dlc & 1)
		frame->data[frame->can_dlc] = 0;


... it would be nice if e.g. Wolfgang could send his patch after some testing,
as i currently don't have access to my MPC5200 hardware here.

Tnx & best regards,
Oliver
