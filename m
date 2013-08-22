From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 1/2] genl: Fix genl dumpit() locking.
Date: Thu, 22 Aug 2013 10:42:01 -0700
Message-ID: <CALnjE+qgZ_UZ4GdiZ4UCzfTLn-OveoHtE28uQZokz2kPD4srXQ@mail.gmail.com>
References: <1377143882-20717-1-git-send-email-pshelar@nicira.com>
	<1377156980.14110.16.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:53314 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753262Ab3HVRmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 13:42:03 -0400
Received: by mail-qa0-f43.google.com with SMTP id cl20so479921qab.2
        for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 10:42:01 -0700 (PDT)
In-Reply-To: <1377156980.14110.16.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 22, 2013 at 12:36 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Wed, 2013-08-21 at 20:58 -0700, Pravin B Shelar wrote:
>> In case of genl-family with parallel ops off, dumpif() callback
>> is expected to run under genl_lock, But commit def3117493eafd9df
>> (genl: Allow concurrent genl callbacks.) changed this behaviour
>> where only first dumpit() op was called under genl-lock.
>> For subsequent dump, only nlk->cb_lock was taken.
>> Following patch fixes it by defining locked dumpit() and done()
>> callback which takes care of genl-locking.
>
> As I've commented over in the other thread, I really think this is the
> wrong thing to do. It was never the case that dumpit() was actually
> locked under genl_lock(), and adding it doesn't really help anyone.
>
If you look at commit def3117493eafd9df , it removes assignment of
cb_mutex to genl_mutex. Thats how genl-dump operation was called under
genl_mutex.
This patch simply restores that locking.
