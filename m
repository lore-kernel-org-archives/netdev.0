From: Patrick McHardy <kaber@trash.net>
Subject: Re: Problem using iptables MARK from tc.
Date: Mon, 12 Jan 2009 05:10:25 +0100
Message-ID: <496AC2B1.4010603@trash.net>
References: <1231248276.11025.148.camel@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54746 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbZALEKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 23:10:41 -0500
In-Reply-To: <1231248276.11025.148.camel@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Henriksson wrote:
> Hello Patrick and co.
> 
> I was hoping you might have some time to help out with a problem in tc
> related to iptables modules. A bit of historical knowledge about
> libipt_MARK.c is probably useful.
> 
> The full bug-report is available at:
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=510924
> 
> In iproute2's tc/m_ipt.c there's a function called get_target_name with
> some logic to look up a symbol with the same name as the so-file. (ie.
> "mark" for libipt_MARK.so or libxt_MARK.so).
> There seems to have been a structure with that name in the past, but
> nowadays there are several ones which are jacked in with a registration
> hook.
> 
> Does this sound about right? Do you have any suggestions on how the tc
> modules functionality could be fixed up to find what it needs properly?
> The structures doesn't even seem to be exported in the ABI anymore...

We've added a shared library to iptables so m_ipt doesn't have
to reimplement things, which is pretty much guaranteed to break
occasionally. It doesn't contain all the functionality thats
needed yet, but it should be fairly easy to add. Most likely
you just need to move the code around.

