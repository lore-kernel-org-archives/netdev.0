From: roopa <roopa@cumulusnetworks.com>
Subject: Re: iproute2: ip -force -batch does not continue on errors
Date: Tue, 17 Mar 2015 08:17:14 -0700
Message-ID: <5508457A.7070405@cumulusnetworks.com>
References: <alpine.DEB.2.11.1503171550360.18888@aurora64.sdinet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sven-Haegar Koch <haegar@sdinet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:32971 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752493AbbCQPRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 11:17:16 -0400
Received: by pdnc3 with SMTP id c3so12378349pdn.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 08:17:15 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.11.1503171550360.18888@aurora64.sdinet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/17/15, 8:07 AM, Sven-Haegar Koch wrote:
> Hallo,
>
> Test szenario:
>
> # cat b.txt
> route del 1.2.3.0/24 dev eth0
> route del 1.2.4.0/24 dev eth0
> route del 1.2.5.0/24 dev eth0
> route add 1.2.3.0/24 dev eth0
>
> # ip -force -batch b.txt
> RTNETLINK answers: No such process
>
> Expectation: The three route del commands may fail if the route does
> not (yet) exist, and then (as I am using -force) the route add gets
> executed.
>
> But instead the batch processing is aborted at the first failing "route
> del" command, forcing me to execute ip once per route del instead of
> using the batchmode.
>
> Tested mainly using iproute2 3.16.0, but the current git tree seems to
> behave mostly the same, except that it only executes anything if I add
> "-f inet" to the commandline, otherwise it rejects the first line with
> 'Error: an inet prefix is expected rather than "1.2.3.0/24".'
>

I have run into this as well, I have a patch that fixes this. Will post 
it today...
