From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v6 4/7 RFC] TCPCT part 1d: define TCP cookie
 option, extend existing struct's
Date: Mon, 16 Nov 2009 17:09:17 -0500
Message-ID: <4B01CD8D.1000305@gmail.com>
References: <4AFCDA9E.8050003@gmail.com> <4AFCE65C.2010104@gmail.com> <4AFCFD86.6020504@gmail.com> <4AFD8421.6090003@gmail.com> <4B01BB33.7080702@gmail.com> <4B01BF65.1010203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:36181 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798AbZKPWJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 17:09:15 -0500
Received: by yxe17 with SMTP id 17so292082yxe.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 14:09:20 -0800 (PST)
In-Reply-To: <4B01BF65.1010203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> I am a bit uneasy on this patch, since apparently you have infrastructure
> to send DATA payload on SYN, but I thought it was an optional part of your 'RFC'
> and as such, being implemented later ?
> 
There is nothing yet in this patch series to send data with a SYN.  Back in
early October, David required that the various s_data and cookie structures
be compressed and consolidated.  So, for the client side, the cookie_*
fields are filled and the s_data_* fields are zero (ignored), while the
server side can have both filled.

Moreover, *this* patch does nothing other than allocate and deallocate the
structure, zero filled by kzalloc().

SYN data will be implemented (much) later.


> I remember a previous remark from David that our skb queues would not contain
> DATA on SYN packets...
> 
I haven't seen anything by David, but there's an existing comment in
tcp_input.c at the place where SYN data will be added later:

			/* Now we have several options: In theory there is
			 * nothing else in the frame. KA9Q has an option to
			 * send data with the syn, BSD accepts data with the
			 * syn up to the [to be] advertised window and
			 * Solaris 2.1 gives you a protocol error. For now
			 * we just ignore it, that fits the spec precisely
			 * and avoids incompatibilities. It would be nice in
			 * future to drop through and process the data.

As you know, there's an old Linux t/tcp patch series out there to add SYN
data.  I'm also working with my KA9Q and BSD sources.
