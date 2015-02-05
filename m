From: Andy Zhou <azhou@nicira.com>
Subject: Re: [ovs-dev] [RFC: add openvswitch actions using BPF 5/9] bpf: add
 the first BPF program.
Date: Thu, 5 Feb 2015 11:16:17 -0800
Message-ID: <CACzMAJ+5BdmXRGN1L5U84Sk1efag=04C4Bz0FxM83c=5MUazuQ@mail.gmail.com>
References: <1423090163-19902-1-git-send-email-azhou@nicira.com>
	<1423090163-19902-6-git-send-email-azhou@nicira.com>
	<20150205141854.GD5546@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.com" <dev@openvswitch.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:38022 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751413AbbBETQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 14:16:18 -0500
Received: by mail-ob0-f175.google.com with SMTP id va2so8812866obc.6
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 11:16:17 -0800 (PST)
In-Reply-To: <20150205141854.GD5546@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 5, 2015 at 6:18 AM, Thomas Graf <tgraf@noironetworks.com> wrote:
> First of all, I *love* this. I have some questions on versioning of
> helpers in the kernel. I will put comments in the respective kernel
> patches directly.
>
Thanks for the feedbacks.
> On 02/04/15 at 02:49pm, Andy Zhou wrote:
>> +EXTRA_DIST += $(srcdir)/bpf/ovs-bpf-helpers.h \
>> +           $(srcdir)/bpf/bpf-shared.h \
>> +           $(srcdir)/bpf/ovs-actions.c
>> +
>> +DEP_FILES  = $(srcdir)/bpf/ovs-bpf-helpers.h \
>> +          $(srcdir)/bpf/bpf-shared.h \
>> +             $(srcdir)/datapath/linux/compat/include/linux/openvswitch.h
>
> Some tab / space mixing here.
Will fix.
>
>> +bpf/ovs-actions.bpf: $(srcdir)/bpf/ovs-actions.c $(DEP_FILES)
>> +     $(AM_V_GEN)clang -DHAVE_CONFIG_H $(BPF_INCLUDES) $(NOSTDINC_FLAGS) \
>> +             $(AM_CFLAGS) $(EXTRA_CFLAGS) -Wno-unused-value -Wno-pointer-sign \
>> +             -O2 -emit-llvm -c $< -o -| $(LLC) -filetype=obj -o $@
>
> I assume you will convert this to a Makefile template
Yes. It needs to be addressed.  Not sure if additional changes are
required now that
BPF backend is merged into LLVM upstream,
