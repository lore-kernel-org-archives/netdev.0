From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 3/6] ebpf: add a way to dump an eBPF program
Date: Fri, 4 Sep 2015 14:48:03 -0700
Message-ID: <CALCETrW5fS5d73ASJvhUuK=Yret7hcWD-B9NhZ3EsnCaw0MWFQ@mail.gmail.com>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-4-git-send-email-tycho.andersen@canonical.com>
 <CAGXu5jJ5+EFDRpgJC6U8Y4nvPEh2fivi-TZRNC-4qP9Gi7B7pA@mail.gmail.com> <20150904204554.GO26679@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33555 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933881AbbIDVsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 17:48:23 -0400
Received: by obbbh8 with SMTP id bh8so27191671obb.0
        for <netdev@vger.kernel.org>; Fri, 04 Sep 2015 14:48:22 -0700 (PDT)
In-Reply-To: <20150904204554.GO26679@smitten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 4, 2015 at 1:45 PM, Tycho Andersen
<tycho.andersen@canonical.com> wrote:
> On Fri, Sep 04, 2015 at 01:17:30PM -0700, Kees Cook wrote:
>> On Fri, Sep 4, 2015 at 9:04 AM, Tycho Andersen
>> <tycho.andersen@canonical.com> wrote:
>> > This commit adds a way to dump eBPF programs. The initial implementation
>> > doesn't support maps, and therefore only allows dumping seccomp ebpf
>> > programs which themselves don't currently support maps.
>> >
>> > We export the GPL bit as well as a unique ID for the program so that
>>
>> This unique ID appears to be the heap address for the prog. That's a
>> huge leak, and should not be done. We don't want to introduce new
>> kernel address leaks while we're trying to fix the remaining ones.
>> Shouldn't the "unique ID" be the fd itself? I imagine KCMP_FILE
>> could be used, for example.
>
> No; we acquire the fd per process, so if a task installs a filter and
> then forks N times, we'll grab N (+1) copies of the filter from N (+1)
> different file descriptors. Ideally, we'd have some way to figure out
> that these were all the same. Some sort of prog_id is one way,
> although there may be others.

I disagree a bit.  I think we want the actual hierarchy to be a
well-defined thing, because I have plans to make the hierarchy
actually do something.  That means that we'll need to have a more
exact way to dump the hierarchy than "these two filters are identical"
or "these two filters are not identical".

--Andy
