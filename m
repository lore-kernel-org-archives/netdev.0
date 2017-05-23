From: Andy Lutomirski <luto@kernel.org>
Subject: Re: [kernel-hardening] [PATCH v4 next 0/3] modules: automatic module
 loading restrictions
Date: Tue, 23 May 2017 12:50:25 -0700
Message-ID: <CALCETrXiaBweijZ22Lwb_pQY934ejcXtEG2EW3nRxe7cEx7PDw@mail.gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
 <20170522120848.GA3003@openwall.com> <CAEiveUdqfMk4+vLg6TaEJNSGwoQHxYq0P4aqZoL4i9GgR3Vdtw@mail.gmail.com>
 <20170522164323.GA2048@openwall.com> <CAEiveUdb=yc5Gt_+pU_hfNdoNBP0JsUL1QUydNZgc2tD7n1h1w@mail.gmail.com>
 <CAGXu5jKGnG74KE-k9JPaH1bNqT5nbVioaeu_5sAKQ+4kgp-0Ng@mail.gmail.com>
 <20170523074808.GA4562@openwall.com> <CAGXu5jJ-zpqU9v44=bc0GnQP5zcKtceR_7DBQVBZ=vy3OvNx9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Solar Designer <solar@openwall.com>,
        Djalal Harouni <tixxdz@gmail.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Andy Lutomirski <luto@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Rusty Russell <rusty@rustcorp.com.au>,
        "Serge E. Hallyn" <serge@hallyn.com>, Jessica Yu <jeyu@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <paul@paul-moore.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
        Ingo Molnar <mingo@kernel.org>
To: Kees Cook <keescook@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:43810 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933846AbdEWTus (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 15:50:48 -0400
Received: from mail-ua0-f181.google.com (mail-ua0-f181.google.com [209.85.217.181])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 40C472397C
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 19:50:47 +0000 (UTC)
Received: by mail-ua0-f181.google.com with SMTP id j17so84623632uag.3
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 12:50:47 -0700 (PDT)
In-Reply-To: <CAGXu5jJ-zpqU9v44=bc0GnQP5zcKtceR_7DBQVBZ=vy3OvNx9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 23, 2017 at 11:36 AM, Kees Cook <keescook@google.com> wrote:
> On Tue, May 23, 2017 at 12:48 AM, Solar Designer <solar@openwall.com> wrote:
>> For modules_autoload_mode=2, we already seem to have the equivalent of
>> modprobe=/bin/true (or does it differ subtly, maybe in return values?),
>> which I already use at startup on a GPU box like this (preloading
>> modules so that the OpenCL backends wouldn't need the autoloading):
>>
>> nvidia-smi
>> nvidia-modprobe -u -c=0
>> #modprobe nvidia_uvm
>> #modprobe fglrx
>>
>> sysctl -w kernel.modprobe=/bin/true
>> sysctl -w kernel.hotplug=/bin/true
>>
>> but it's good to also have this supported more explicitly and more
>> consistently through modules_autoload_mode=2 while we're at it.  So I
>> support having this mode as well.  I just question the need to have it
>> non-resettable.
>
> I agree it's useful to have the explicit =2 state just to avoid
> confusion when more systems start implementing
> CONFIG_STATIC_USERMODEHELPER and kernel.modprobe becomes read-only
> (though the userspace implementation may allow for some way to disable
> it, etc). I just like avoiding the upcall to modprobe at all.

I fully support =2 to mean "no automatic loading at all".  I dislike
making it non-resettable.  If you can write to sysctls, then, most
likely you can either call init_module() directly or the system has
module loading disabled entirely.
