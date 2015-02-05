From: Thomas Graf <tgraf@noironetworks.com>
Subject: Re: [ovs-dev] [RFC: add openvswitch actions using BPF 5/9] bpf: add
 the first BPF program.
Date: Thu, 5 Feb 2015 15:18:54 +0100
Message-ID: <20150205141854.GD5546@pox.localdomain>
References: <1423090163-19902-1-git-send-email-azhou@nicira.com>
 <1423090163-19902-6-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.com, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:40389 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbbBEOS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 09:18:57 -0500
Received: by mail-wi0-f178.google.com with SMTP id bs8so10838279wib.5
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 06:18:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1423090163-19902-6-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First of all, I *love* this. I have some questions on versioning of
helpers in the kernel. I will put comments in the respective kernel
patches directly.

On 02/04/15 at 02:49pm, Andy Zhou wrote:
> +EXTRA_DIST += $(srcdir)/bpf/ovs-bpf-helpers.h \
> +	      $(srcdir)/bpf/bpf-shared.h \
> +	      $(srcdir)/bpf/ovs-actions.c
> +
> +DEP_FILES  = $(srcdir)/bpf/ovs-bpf-helpers.h \
> +	     $(srcdir)/bpf/bpf-shared.h \
> +             $(srcdir)/datapath/linux/compat/include/linux/openvswitch.h

Some tab / space mixing here.

> +bpf/ovs-actions.bpf: $(srcdir)/bpf/ovs-actions.c $(DEP_FILES)
> +	$(AM_V_GEN)clang -DHAVE_CONFIG_H $(BPF_INCLUDES) $(NOSTDINC_FLAGS) \
> +		$(AM_CFLAGS) $(EXTRA_CFLAGS) -Wno-unused-value -Wno-pointer-sign \
> +		-O2 -emit-llvm -c $< -o -| $(LLC) -filetype=obj -o $@

I assume you will convert this to a Makefile template
