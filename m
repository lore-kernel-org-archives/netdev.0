From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 4/7] ebpf: extend program type/subsystem registration
Date: Tue, 10 Feb 2015 17:37:17 -0800
Message-ID: <CAMEtUuxwdk8RDbUbo8SO9zMU2ELgf-xZynEeT5i5JBNLc2Y_Hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:37630 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbbBKBhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 20:37:38 -0500
Received: by mail-qg0-f54.google.com with SMTP id z60so472777qgd.13
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 17:37:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 4:15 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> When various subsystems/modules start to make use of ebpf
> e.g. cls_bpf, act_bpf, ovs, ... we need to make sure, they
> can register their program types only once.
>
> Moreover, we also need to serialize various registrations,
> currently program type registration is being done without
> locks. (We should make sure to not race in future when we
> allow registration from modules.)
>
> Last but not least, we need to be able to register subsystems
> from module context as it's not sufficient to have them only
> as built-in at all time.

imo that is scary. there is no unregister_type by design,
since I didn't want modules to use bpf.
My concern that if we allow modules to register new program
types we allow bypass of gpl and all safety checks we've
put in place.
Modules will define whatever helper functions they like.
We won't be able to control or even code review this stuff.
I think all types and all helper functions should be built-in.
This way we know what bpf is used for and that it's not abused.
Yes, having all types and helpers built-in creates
some challenges for ovs and tc, but I think it's much
safer long term.
I think for networking one or two prog types will be enough
and hopefully ovs/tc/... will settle on common set of helpers.

'bpf for modules' was one of the topics I wanted to
discuss at netdev01. Looks like we started it early...
