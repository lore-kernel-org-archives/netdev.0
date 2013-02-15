From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 1/1] eventfd: implementation of EFD_MASK flag
Date: Fri, 15 Feb 2013 09:32:37 -0800
Message-ID: <CALCETrWxLiesdRc6v11uaSVnQYXJQwP+gR7reG3x-iU44wV2HA@mail.gmail.com>
References: <1360311077-14474-1-git-send-email-sustrik@250bpm.com>
 <20130214145430.04f8750c.akpm@linux-foundation.org> <511DAEA3.4080201@250bpm.com>
 <20130214212411.55788ec1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Martin Sustrik <sustrik@250bpm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Sha Zhengju <handai.szj@taobao.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>,
	Davide Libenzi <davidel@xmailserver.org>,
	Eric Wong <normalperson@yhbt.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f172.google.com ([209.85.128.172]:45657 "EHLO
	mail-ve0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab3BORc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 12:32:58 -0500
Received: by mail-ve0-f172.google.com with SMTP id cz11so3225860veb.31
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 09:32:57 -0800 (PST)
In-Reply-To: <20130214212411.55788ec1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 14, 2013 at 9:24 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 15 Feb 2013 04:42:27 +0100 Martin Sustrik <sustrik@250bpm.com> wrote:
>
>> > This is a non-back-compatible userspace interface change.  A procfs
>> > file which previously displayed
>> >
>> >     eventfd-count: nnnn
>> >
>> > can now also display
>> >
>> >     eventfd-mask: nnnn
>> >
>> > So existing userspace could misbehave.
>> >
>> > Please fully describe the proposed interface change in the changelog.
>> > That description should include the full pathname of the procfs file
>> > and example before-and-after output and a discussion of whether and why
>> > the risk to existing userspace is acceptable.
>>
>> I am not sure what the policy is here. Is not printing out the state of
>> the object acceptable way to maintain backward compatibility? If not so,
>> does new type of object require new procfs file, which, AFAIU, is the
>> only way to retain full backward compatibility?
>
> Adding a new file is the only way I can think of to preserve the API.
> But from Andy's comment is sounds like we don't have to worry a lot
> about back-compatibility.
>

I'm not even convinced there's an issue in the first place (other than
the fact that use of this feature will break old criu, regardless of
/proc changes).  The fdinfo files already vary by descriptor type.
Anything that screws up if unexpected fields are present is already
screwed.

--Andy
