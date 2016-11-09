From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: 484611357c19 introduces arbitrary kernel write bug (root-only)
Date: Tue, 8 Nov 2016 17:04:53 -0800
Message-ID: <CALCETrXnqoPD8X1R6v4vZZatrA=fJdn6NTs-zaNqd6Qc4qMJNQ@mail.gmail.com>
References: <CAG48ez0mP4xwv6vnKRJ+rcdXYyA1wGnCWsbkKUgWGSBbMtgFMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Josef Bacik <jbacik@fb.com>,
        "security@kernel.org" <security@kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Jann Horn <jannh@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:34416 "EHLO
        mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751032AbcKIBFO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 20:05:14 -0500
Received: by mail-vk0-f52.google.com with SMTP id x186so164002268vkd.1
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 17:05:14 -0800 (PST)
In-Reply-To: <CAG48ez0mP4xwv6vnKRJ+rcdXYyA1wGnCWsbkKUgWGSBbMtgFMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 8, 2016 at 4:23 PM, Jann Horn <jannh@google.com> wrote:
> In 484611357c19 (not in any stable kernel yet), functionality is
> introduced that allows root (and afaics nobody else, since nobody else
> is allowed to perform pointer arithmetic) to basically write to (and
> read from) arbitrary kernel memory. There are multiple bugs in the
> validation logic:
>

I was curious, so I gave the code a quick read.  I also see:


+       /* PTR_TO_MAP_VALUE_ADJ is used for doing pointer math inside of a map
+        * elem value.  We only allow this if we can statically verify that
+        * access from this register are going to fall within the size of the
+        * map element.
+        */
+       PTR_TO_MAP_VALUE_ADJ,

shouldn't this document what logical type this is?  Is it a pointer?
Is it an offset?  (It seems to be checked as though it's a pointer
with a max offset of "max_value", which makes very little sense to
me.)



regs[i].min_value = BPF_REGISTER_MIN_RANGE;
where min_value is a u64 and BPF_REGISTER_MIN_RANGE is negative.
Shouldn't those be s64?

init_reg_state() duplicates reset_reg_range_values().


That's all I've read so far.
