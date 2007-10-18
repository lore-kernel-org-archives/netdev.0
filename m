From: Rick Jones <rick.jones2@hp.com>
Subject: Re: bizarre network timing problem
Date: Thu, 18 Oct 2007 10:22:18 -0700
Message-ID: <4717964A.8080100@hp.com>
References: <20071017205127.GA21334@codeblau.de> <47167BDE.4000103@redhat.com>	<20071017220019.GA22765@codeblau.de> <471689BF.2040909@hp.com> <20071018094230.GA2978@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <cebbert@redhat.com>, linux-kernel@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>
To: Felix von Leitner <felix-linuxkernel@fefe.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:34626 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752647AbXJRRWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 13:22:21 -0400
In-Reply-To: <20071018094230.GA2978@codeblau.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Felix von Leitner wrote:
>>the packet trace was a bit too cooked perhaps, but there were indications 
>>that at times the TCP window was going to zero - perhaps something with 
>>window updates or persist timers?
> 
> 
> Does TCP use different window sizes on loopback?  Why is this not
> happening on ethernet?

I don't think it uses different window sizes on loopback, but with the 
autotuning it can be difficult to say a priori what the window size will be. 
What one can say with confidence is that the MTU and thus the MSS will be 
different between loopback and ethernet.

> 
> How could I test this theory?

Can you take another trace that isn't so "cooked?"  One that just sticks with 
TCP-level and below stuff?

If SMB is a one-request-at-a-time protocol (I can never remember), you could 
simulate it with a netperf TCP_RR test by passing suitable values to the 
test-specific -r option:

netperf -H <remote> -t TCP_RR -- -r <req>,<rsp>

If that shows similar behaviour then you can ass-u-me it isn't your application. 
  One caveat though is that TCP_CORK mode in netperf is very primitive and may 
not match what you are doing, however, that may be a good thing.

http://www.netperf.org/svn/netperf2/tags/netperf-2.4.4/  or
ftp://ftp.netperf.org/netperf/

to get the current netperf bits.  It is also possible to get multiple 
transactions in flight at one time if you configure netperf with --enable-burst, 
which will then enable a test-specific -b option.  With the latest netperf you 
cna also switch the output of a TCP_RR test to bits or bytes per second a la the 
_STREAM tests.

rick jones

> 
> My initial idea was that it has something todo with the different MTU on
> loopback.  My initial block size was 16k, but the problem stayed when I
> changed it to 64k.
> 
> Felix

