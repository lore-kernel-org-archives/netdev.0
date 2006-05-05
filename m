From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Netem] where i can find this netem patch?
Date: Fri, 5 May 2006 10:15:38 -0700
Message-ID: <20060505101538.5dfc5021@localhost.localdomain>
References: <444FF846.7050600@cmu.edu>
	<32923.128.2.140.234.1146187103.squirrel@128.2.140.234>
	<20060428102421.7d304ca6@localhost.localdomain>
	<445B6A67.7020809@cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl, netem@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:41702 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751163AbWEERPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 13:15:44 -0400
To: George Nychis <gnychis@cmu.edu>
In-Reply-To: <445B6A67.7020809@cmu.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 05 May 2006 11:08:23 -0400
George Nychis <gnychis@cmu.edu> wrote:

> Hi,
> 
> I need help finding this patch that Stephen made.
> 
> He sent me a patch, but i do not think its related to the patch that
> solved this problem.  I will include the patch he did forward to me at
> the bottom.

 
> However here is the problem, i even rtied his misspelling of change :)
>
> thorium-ini 15849-tests # tc qdisc add dev ath0 root handle 1:0 netem
> drop 0%
> thorium-ini 15849-tests # tc qdisc add dev ath0 parent 1:1 handle 10:
> xcp capacity 54Mbit limit 500
> thorium-ini 15849-tests # tc qdisc change dev ath0 root handle 1:0 netem
> drop 1%
> RTNETLINK answers: Invalid argument
>

The problem was you are giving handle 1:0 so the change request was
going to xcp. And xcp doesn't understand netem rtnetlink message.

You want to do:
# tc qdisc change dev ath0 root netem drop 1%

