From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: bcm43xx regression 2.6.19rc3 -> rc5, rtnl_lock trouble?
Date: Thu, 16 Nov 2006 12:17:19 -0600
Message-ID: <455CAB2F.1060709@lwfinger.net>
References: <455B63EC.8070704@madrabbit.org> <200611152015.07844.mb@bu3sch.de> <455B6D74.2020507@madrabbit.org> <455BD219.8080104@lwfinger.net> <455BFC47.3020006@madrabbit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, Bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:54445 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1424248AbWKPSRv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 13:17:51 -0500
To: Ray Lee <ray-lk@madrabbit.org>
In-Reply-To: <455BFC47.3020006@madrabbit.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ray Lee wrote:
> Larry Finger wrote:
>> Ray Lee wrote:
>>> Michael Buesch wrote:
>>>> On Wednesday 15 November 2006 20:01, Ray Lee wrote:
>>>>> Suggestions? Requests for <shudder> even more info?
>>>> Yeah, enable bcm43xx debugging.
>>> Sigh, didn't even think to look for that. Okay, enabled and compiling
>>> a new kernel. This will take a few days to trigger, if the pattern holds, so
>>> in the meantime, any *other* thoughts?
>> Which chip and revision do you have? Send me your equivalent of the line
>> "bcm43xx: Chip ID 0x4306, rev 0x2".
> 
> bcm43xx: Chip ID 0x4306, rev 0x3
> 
> Also, another thing I wasn't clear about in my first email was that the netdev
> watchdog timeouts are new with rc5:
> 
> $ zgrep 'NETDEV WATCH' /var/log/messages{,.0,.1.gz} | cut -d: -f2| cut -c 1-6
> | uniq -c
>    1249 Nov 13
>       6 Nov  6
>       1 Nov  7
>       3 Nov  8
>       2 Nov  9
>    5717 Nov 10
>    5652 Nov 11
>       5 Oct 29
>       3 Oct 30
>       3 Oct 31
>       4 Nov  1
>       1 Nov  2
>       1 Nov  3
> 
> I booted into 2.6.19-rc5 on November 10th. Previous to that was 2.6.19-rc3.
> There really does seem to be something suspicious with that patch, yes?
> 
> Thanks,
> 
> Ray
> 

It certainly looks as if the "Drain TX status" patch is causing the problem; however, it should do 
nothing for core revisions < 5, and yours is a 3.

Could you do me a favor? Please use git to download the current contents of Linus's tree with a "git 
clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git new_dir". Using the same 
.config as your current kernel and the git bisect command, you should be able to isolate the commit 
that is causing the error. I know that it is a lot of work and will take considerable time; however, 
that way we will see if some other change is triggering the problem.

If you need help with the bisect process, please let me know.

Thanks,

Larry

