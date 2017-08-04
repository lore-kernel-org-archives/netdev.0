From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH iproute2] netns: make /var/run/netns bind-mount recursive
Date: Fri, 04 Aug 2017 08:41:28 -0500
Message-ID: <878tizjvqv.fsf@xmission.com>
References: <20170801154609.29895-1-casey.callendrello@coreos.com>
        <20170803160421.58eb0a4a@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Casey Callendrello <casey.callendrello@coreos.com>,
        netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:33159 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752976AbdHDNts (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 09:49:48 -0400
In-Reply-To: <20170803160421.58eb0a4a@xeon-e3> (Stephen Hemminger's message of
        "Thu, 3 Aug 2017 16:04:21 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Tue,  1 Aug 2017 17:46:09 +0200
> Casey Callendrello <casey.callendrello@coreos.com> wrote:
>
>> When ip netns {add|delete} is first run, it bind-mounts /var/run/netns
>> on top of itself, then marks it as shared. However, if there are already
>> bind-mounts in the directory from other tools, these would not be
>> propagated. Fix this by recursively bind-mounting.
>> 
>> Signed-off-by: Casey Callendrello <casey.callendrello@coreos.com>
>> ---
>>  ip/ipnetns.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>
> Looks good, but I want a review by Eric to make sure this doesn't
> break other things.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

I don't see any possible problems with this.  This will just keep all of
the mounts showing up.

It would be really nice if we could at some point detect that a parent
directory is shared (which happens with a common init system) and skip
the steps of the bind mount and making them shared as they are
redundant.  However while that might also solve this issue that is
something for another day.

Eric
