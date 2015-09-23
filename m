From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 3/9] net: Remove e_nobufs label from
 ip_route_input_slow
Date: Tue, 22 Sep 2015 21:04:53 -0600
Message-ID: <560216D5.20408@cumulusnetworks.com>
References: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
 <1442962523-3974-4-git-send-email-dsa@cumulusnetworks.com>
 <877fnhc24l.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36510 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707AbbIWDEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 23:04:49 -0400
Received: by pacbt3 with SMTP id bt3so8603643pac.3
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 20:04:49 -0700 (PDT)
In-Reply-To: <877fnhc24l.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/22/15 8:15 PM, Eric W. Biederman wrote:
> David Ahern <dsa@cumulusnetworks.com> writes:
>
>> e_nobufs has 1 user. Move setting err to -ENOBUFS for the 1 user and
>> use the goto out label instead of e_nobufs. Stepping stone patch; next
>> one moves rth code into a helper function.
>
> Ick you are pessimizing the code.
>
> You will almost certainly have better code generation if you hoist
> the assignment of "err = -ENOBUFS" above the rt_dst_alloc then you
> don't need to do anything in your error path except "goto out;"

Can't do that here because the current value of err is used later in:
rth->dst.error = -err;

Besides, as mentioned above this is a stepping stone patch all of this 
is moved to a helper in patch 4. Where I could do the assignment before 
the rt_dst_alloc since I put the original err as an input arg rth_err.

David
