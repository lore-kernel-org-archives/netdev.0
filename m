From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: QoS weirdness : HTB accuracy
Date: Tue, 18 May 2010 18:07:12 -0600
Message-ID: <4BF32BB0.7010700@redfish-solutions.com>
References: <067c83163988908ef546d7ff7f560a17@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	netfilter <netfilter@vger.kernel.org>
To: Julien Vehent <julien@linuxwall.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:46162 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752846Ab0ESAVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 20:21:20 -0400
In-Reply-To: <067c83163988908ef546d7ff7f560a17@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/25/2010 12:06 PM, Julien Vehent wrote:
> Hello folks,
>
> I observe unused bandwidth on my QoS policy that I cannot explain.
> Conditions are: I have a HTB tree with 8 classes and a total rate of
> 768kbits. I use the ATM option so I assume the real rate to be something
> close to 675kbits (about 88% of the ethernet rate).
>
> The sum of my 8 rates is exactly 768kbits. Some have ceil values up to
> 768kbits.
>
> When class 20 "tcp_acks" starts borrowing, TC reduces the total bandwidth
> down to 595kbits/S (minus 79kbits/s). And I can't explain why....
>
> The attached graph "tc_htb_weirdness.png" shows the result: there are
> 'holes' in the sending rate. 
>
> I tried to play with burst sizes, r2q value and hysteresis mode, but the
> results are the same.
>
> System is debian squeeze, kernel version is 2.6.26, iproute2 version is
> 2.6.26 - 07/25/2008.
>
> I have attached two files:
> - "tcrules.txt" : the traffic control rules
> - "tc_htb_weirdness.png" : the rrdtool graph, resolution is 1 second.
>
> And here: http://jve.linuxwall.info/ressources/code/tc_hole_analysis.html
> a sheet with some of the measures values. I used it to calculate the size
> of one of the hole. The last table (with green and red cells) shows that,
> when class 20 "tcp_acks" starts sending at unixtime 1265496813, there is a
> lot of bandwidth left over (last column is all green). During the 95
> seconds while class 20 is sending, 3880776 bits could be sent but are not.
> That's about 40kbits/s on average. 
>
> Does anybody observess the same behavior? Any logical explanation to this
> or is it a bug ?
>
>
> Julien

Sorry for the late response:  could this be an "aliasing" issue caused
by sampling intervals (granularity)?

-Philip

