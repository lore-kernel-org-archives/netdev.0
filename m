From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/9] net: Remove e_inval label from
 ip_route_input_slow
Date: Wed, 23 Sep 2015 11:13:37 -0600
Message-ID: <5602DDC1.2080403@cumulusnetworks.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
 <1443021322-48621-3-git-send-email-dsa@cumulusnetworks.com>
 <5602C901.2050404@gmail.com> <5602CD17.3030008@cumulusnetworks.com>
 <5602D3CA.7010502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36671 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648AbbIWRNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 13:13:42 -0400
Received: by pacgz1 with SMTP id gz1so11587748pac.3
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 10:13:41 -0700 (PDT)
In-Reply-To: <5602D3CA.7010502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/23/15 10:31 AM, Alexander Duyck wrote:
>
> Just as you said, that code would be an intermediate step.  Going though
> and adding more points where you are updating err and just exchanging
> one jump label for another doesn't help anything.  You are better off
> pulling apart the spaghetti right from the start and then rearranging
> the code.  If nothing else it helps to make things more readable.
>
> In a couple of patches from here you are going to have to pull out the
> local_input helper.  Rather than adding a new jump label inside of it
> for out you could save yourself a few steps and just return the error
> values.  If you do this correctly what you should end up with is a
> series of functions that all converge on one end point anyway.
>
> Also as far as the multiple returns issue it isn't much of a problem
> since ip_output_input_slow ends up being compiled into
> ip_route_input_noref anyway.  As such the return statements end up just
> being jumps to the bits for the rcu_read_unlock and returning the error
> value.

I chose this series of steps because it is easy to follow each change to 
ensure I do not introduce bugs with the patches. Small, focused changes 
to evolve the code.

The first 3 patches appear to have *zero* impact on what the compiler 
generates.

Do you object to the end result of this patch series? ie. do you have 
concerns about what the end code looks like?
