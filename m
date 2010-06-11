From: jellyaaa <wgdaaa@126.com>
Subject: puzzled of the congestion control window of Scalable TCP
Date: Thu, 10 Jun 2010 18:15:35 -0700 (PDT)
Message-ID: <28850421.post@talk.nabble.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kuber.nabble.com ([216.139.236.158]:54454 "EHLO
	kuber.nabble.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760024Ab0FKBPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 21:15:36 -0400
Received: from isper.nabble.com ([192.168.236.156])
	by kuber.nabble.com with esmtp (Exim 4.63)
	(envelope-from <lists@nabble.com>)
	id 1OMsqN-0000pW-4q
	for netdev@vger.kernel.org; Thu, 10 Jun 2010 18:15:35 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I am now doing something related to the STCP (Scalable TCP). By pringking the
dynamic snd_cwnd in linux (kernel 2.6.18) ,the result puzzled me . Theoryly,
if any congestion occurs, the snd_cwnd = snd_cwnd * 0.875,but I haven't got
the result I expected. The snd_cwnd changes like this :

snd_cwnd = 1 , snd_ssthresh = 2147483647
snd_cwnd = 2 , snd_ssthresh = 2147483647
snd_cwnd = 3, snd_ssthresh = 2147483647
......
snd_cwnd = 19022, snd_ssthresh = 2147483647      // keeping this value for
several ms 
snd_cwnd = 1769, snd_ssthresh = 16645        // congestion occurs 
snd_cwnd = 1770, snd_ssthresh = 16645                  
......


>From the above data. when congestion occurs , snd_ssthresh = 16645 ~=~
19022*0.875=16626 corresponds  to the theory calculated result. no problems. 
but what is the mean of snd_cwnd = 1770? how this value is calculated .who
(where )calculated it ?


-- 
View this message in context: http://old.nabble.com/puzzled-of-the-congestion-control-window-of-Scalable-TCP-tp28850421p28850421.html
Sent from the netdev mailing list archive at Nabble.com.

