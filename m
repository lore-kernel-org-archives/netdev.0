From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 1/2] genl: Fix genl dumpit() locking.
Date: Thu, 22 Aug 2013 11:10:21 -0700
Message-ID: <CALnjE+rEOMmyFQ0Nx3-O-Cvu8yePVBg7x8vgpGUOAAnYv3KG4Q@mail.gmail.com>
References: <1377143882-20717-1-git-send-email-pshelar@nicira.com>
	<1377156980.14110.16.camel@jlt4.sipsolutions.net>
	<CALnjE+qgZ_UZ4GdiZ4UCzfTLn-OveoHtE28uQZokz2kPD4srXQ@mail.gmail.com>
	<1377193906.14110.27.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:36118 "HELO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753388Ab3HVSKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 14:10:22 -0400
Received: by mail-qe0-f46.google.com with SMTP id f6so1308840qej.33
        for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 11:10:21 -0700 (PDT)
In-Reply-To: <1377193906.14110.27.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 22, 2013 at 10:51 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Thu, 2013-08-22 at 10:42 -0700, Pravin Shelar wrote:
>> On Thu, Aug 22, 2013 at 12:36 AM, Johannes Berg
>> <johannes@sipsolutions.net> wrote:
>> > On Wed, 2013-08-21 at 20:58 -0700, Pravin B Shelar wrote:
>> >> In case of genl-family with parallel ops off, dumpif() callback
>> >> is expected to run under genl_lock, But commit def3117493eafd9df
>> >> (genl: Allow concurrent genl callbacks.) changed this behaviour
>> >> where only first dumpit() op was called under genl-lock.
>> >> For subsequent dump, only nlk->cb_lock was taken.
>> >> Following patch fixes it by defining locked dumpit() and done()
>> >> callback which takes care of genl-locking.
>> >
>> > As I've commented over in the other thread, I really think this is the
>> > wrong thing to do. It was never the case that dumpit() was actually
>> > locked under genl_lock(), and adding it doesn't really help anyone.
>> >
>> If you look at commit def3117493eafd9df , it removes assignment of
>> cb_mutex to genl_mutex. Thats how genl-dump operation was called under
>> genl_mutex.
>
> By the way - why? This just means that netlink will allocate another
> lock to lock it all, so it's not a very useful change?
>
This replaces global genl-lock with per-socket lock which allows
parallel operation in parallel-genl-families and they are not blocked
due to other unrelated genl-family operations.
