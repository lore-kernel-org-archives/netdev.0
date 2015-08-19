From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 7/9] geneve: Consolidate Geneve functionality
 in single module.
Date: Wed, 19 Aug 2015 11:49:32 -0700
Message-ID: <CALnjE+rmdPOAFo876pZr-vtr=YmGZopSNPC02Qb3J0Wx3GBz1w@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
	<1439845905-31666-8-git-send-email-pshelar@nicira.com>
	<CAEP_g=_4FHejf_qfXbXzO3kyx1WJ2ssOY9OMF=vySFNu-CPOqA@mail.gmail.com>
	<CALnjE+ojRD_QKY3A9EomCg6yZ2BR+jiSFjndzN+U+8aBP2b7GQ@mail.gmail.com>
	<CAEP_g=8Wq1jmrWT6a9K55JJsMNxw+Rw0h2zDby_HR6b12LJ5+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:34799 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101AbbHSSte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 14:49:34 -0400
Received: by igui7 with SMTP id i7so115145934igu.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 11:49:33 -0700 (PDT)
In-Reply-To: <CAEP_g=8Wq1jmrWT6a9K55JJsMNxw+Rw0h2zDby_HR6b12LJ5+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 11:37 AM, Jesse Gross <jesse@nicira.com> wrote:
> On Wed, Aug 19, 2015 at 11:29 AM, Pravin Shelar <pshelar@nicira.com> wrote:
>> On Wed, Aug 19, 2015 at 11:18 AM, Jesse Gross <jesse@nicira.com> wrote:
>>> My guess is that if the issue from the earlier patch about overlapping
>>> collect_md tunnels is fixed then that might allow us to simplify
>>> things a little further, since for those tunnels we can assume there
>>> is a 1:1 mapping between collect_md tunnels and sockets.
>>
>> I dont see how it would be different. Can you elaborate on this ?
>
> Mostly just conceptually simpler. Right now it looks like we are doing
> some kind of refcounting between devices and tunnels in
> geneve_open/stop (I know it's not really but it appears like that in
> some ways.) We could just directly assign collect_md in geneve_open()
> and do nothing at all in geneve_stop().

If you look at next patch, I have changed geneve_open and stop
further. The change is geneve_open adds tunnel to hash table so that
only device which are open are in hash table. Since geneve_open and
stop is common for both type of tunnel I do not think there can be any
changes even after avoiding overlapping tunnel types in given socket.
