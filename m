From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 5/6] geneve: Consolidate Geneve functionality in
 single module.
Date: Thu, 13 Aug 2015 14:24:05 -0700
Message-ID: <CAEP_g=-BUb8Uyh3hYGt3b=J62fW9Kvm+yf3ySZwVOmMurKNf1g@mail.gmail.com>
References: <1439356673-21844-1-git-send-email-pshelar@nicira.com>
 <CAEP_g=8zvvosyueA-gudpYq1pCi4dCusW33wcCscpga8JLWz-w@mail.gmail.com> <CALnjE+pzgLwWgqYjE2wwyvbLUQ9fkX+4VJo_Ow44pHV0hhRbGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:33868 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754173AbbHMVY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 17:24:26 -0400
Received: by labd1 with SMTP id d1so33639269lab.1
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 14:24:25 -0700 (PDT)
In-Reply-To: <CALnjE+pzgLwWgqYjE2wwyvbLUQ9fkX+4VJo_Ow44pHV0hhRbGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2015 at 4:33 PM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Wed, Aug 12, 2015 at 2:55 PM, Jesse Gross <jesse@nicira.com> wrote:
>> The farther I go in the series, the more that I hope that we can avoid
>> the use of collect_md_tun. It really seems to add a lot of special
>> cases.
>
> Use of collect_md_tun allows us to avoid hash table lookup. thats why
> I did it. Anyways we need a flag or pointer in geneve-sock structure
> to locate tunnel metadata. I dont see how is it simple if
> collect_md_tun is replaced with a flag.

It seems to me that this requires more bookkeeping to keep consistent
(a little in the code but mostly mentally) because collect_md_tun is a
separate concept that doesn't necessarily follow the same rules as
other tunnels. With VXLAN, I feel like I can mostly ignore this tunnel
since it isn't special in most ways with the exception of places where
it actually needs to do something different like allocate metadata.
