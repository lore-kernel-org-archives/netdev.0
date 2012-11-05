From: Mohammad Alsaleh <msal@tormail.org>
Subject: Re: ping -f is broken in iputils 20121011
Date: Mon, 5 Nov 2012 18:37:57 +0300
Message-ID: <1TVOjm-000HkS-JO@internal.tormail.org>
References: <5097841F.2050905@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Synacek <jsynacek@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outgoing.tormail.org ([82.221.96.22]:55424 "EHLO
	outgoing.tormail.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab2KEPkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 10:40:08 -0500
Content-Disposition: inline
In-Reply-To: <5097841F.2050905@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>On 10/31/2012 10:11 AM, Mohammad Alsaleh wrote:
>> On Tue, Oct 30, 2012 at 11:52:49PM +0300, Mohammad Alsaleh wrote:
>>> As explained in this bug report(1). ping -f seems to be broken in
>>> iputils 20121011.
>>>
>>> (1) https://bugs.archlinux.org/task/32306
>> 
>> Bisected to commit 8feb586c4c6df32badb159947ed233898891aecd
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>
>Can you please try the attached patch?
>
>-- 
>Jan Synacek
>Software Engineer, BaseOS team Brno, Red Hat
>
>--- iputils-s20121011/ping_common.h	2012-11-05 10:07:40.065281888
>+0100
>+++ iputils-s20121011-new/ping_common.h	2012-11-05 10:07:22.001268362
>+0100
>@@ -141,7 +141,7 @@ static inline void write_stdout(const ch
> 	do {
> 		cc = write(STDOUT_FILENO, str + o, len - o);
> 		o += cc;
>-	} while (len >= o || cc < 0);
>+	} while (len > o || cc < 0);
> }
> 
> /*
>--- iputils-s20121011/ping_common.c	2012-11-05 10:07:40.066281889
>+0100
>+++ iputils-s20121011-new/ping_common.c	2012-11-05 10:07:22.007268368
>+0100
>@@ -776,7 +776,7 @@ restamp:
> 		if (!csfailed)
> 			write_stdout("\b \b", 3);
> 		else
>-			write_stdout("\bC", 1);
>+			write_stdout("\bC", 2);
> 	} else {
> 		int i;
> 		__u8 *cp, *dp;
>

Sorry if this reply does not appear in the right thread. I'm not
subscribed to the list.

I can confirm the patch fixes the bug.
