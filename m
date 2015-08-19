From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 7/9] geneve: Consolidate Geneve functionality
 in single module.
Date: Wed, 19 Aug 2015 11:37:38 -0700
Message-ID: <CAEP_g=8Wq1jmrWT6a9K55JJsMNxw+Rw0h2zDby_HR6b12LJ5+w@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
 <1439845905-31666-8-git-send-email-pshelar@nicira.com> <CAEP_g=_4FHejf_qfXbXzO3kyx1WJ2ssOY9OMF=vySFNu-CPOqA@mail.gmail.com>
 <CALnjE+ojRD_QKY3A9EomCg6yZ2BR+jiSFjndzN+U+8aBP2b7GQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:33512 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbbHSSh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 14:37:59 -0400
Received: by lbbsx3 with SMTP id sx3so9123872lbb.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 11:37:57 -0700 (PDT)
In-Reply-To: <CALnjE+ojRD_QKY3A9EomCg6yZ2BR+jiSFjndzN+U+8aBP2b7GQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 11:29 AM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Wed, Aug 19, 2015 at 11:18 AM, Jesse Gross <jesse@nicira.com> wrote:
>> My guess is that if the issue from the earlier patch about overlapping
>> collect_md tunnels is fixed then that might allow us to simplify
>> things a little further, since for those tunnels we can assume there
>> is a 1:1 mapping between collect_md tunnels and sockets.
>
> I dont see how it would be different. Can you elaborate on this ?

Mostly just conceptually simpler. Right now it looks like we are doing
some kind of refcounting between devices and tunnels in
geneve_open/stop (I know it's not really but it appears like that in
some ways.) We could just directly assign collect_md in geneve_open()
and do nothing at all in geneve_stop().
