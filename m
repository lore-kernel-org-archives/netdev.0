From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 V3 3/4] rdma: Add link object
Date: Mon, 10 Jul 2017 20:28:28 +0200
Message-ID: <20170710182828.GF1853@nanopsycho>
References: <20170704075541.12544-1-leon@kernel.org>
 <20170704075541.12544-4-leon@kernel.org>
 <20170710081307.GE1853@nanopsycho>
 <20170710162223.GO1528@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33094 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752509AbdGJS2b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 14:28:31 -0400
Received: by mail-wr0-f194.google.com with SMTP id x23so26750897wrb.0
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 11:28:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170710162223.GO1528@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 10, 2017 at 06:22:23PM CEST, leon@kernel.org wrote:
>On Mon, Jul 10, 2017 at 10:13:07AM +0200, Jiri Pirko wrote:
>> Tue, Jul 04, 2017 at 09:55:40AM CEST, leon@kernel.org wrote:
>> >From: Leon Romanovsky <leonro@mellanox.com>
>> >
>> >Link (port) object represent struct ib_port to the user space.
>> >
>> >Link properties:
>> > * Port capabilities
>> > * IB subnet prefix
>> > * LID, SM_LID and LMC
>> > * Port state
>> > * Physical state
>> >
>> >Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
>> >---
>> > rdma/Makefile |   2 +-
>> > rdma/link.c   | 280 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>> > rdma/rdma.c   |   3 +-
>> > rdma/utils.c  |   5 ++
>> > 4 files changed, 288 insertions(+), 2 deletions(-)
>> > create mode 100644 rdma/link.c
>> >
>> >diff --git a/rdma/Makefile b/rdma/Makefile
>> >index 123d7ac5..1a9e4b1a 100644
>> >--- a/rdma/Makefile
>> >+++ b/rdma/Makefile
>> >@@ -2,7 +2,7 @@ include ../Config
>> >
>> > ifeq ($(HAVE_MNL),y)
>> >
>> >-RDMA_OBJ = rdma.o utils.o dev.o
>> >+RDMA_OBJ = rdma.o utils.o dev.o link.o
>> >
>> > TARGETS=rdma
>> > CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
>> >diff --git a/rdma/link.c b/rdma/link.c
>> >new file mode 100644
>> >index 00000000..f92b4cef
>> >--- /dev/null
>> >+++ b/rdma/link.c
>> >@@ -0,0 +1,280 @@
>> >+/*
>> >+ * link.c	RDMA tool
>> >+ *
>> >+ *              This program is free software; you can redistribute it and/or
>> >+ *              modify it under the terms of the GNU General Public License
>> >+ *              as published by the Free Software Foundation; either version
>> >+ *              2 of the License, or (at your option) any later version.
>> >+ *
>> >+ * Authors:     Leon Romanovsky <leonro@mellanox.com>
>> >+ */
>> >+
>> >+#include "rdma.h"
>> >+
>> >+static int link_help(struct rdma *rd)
>> >+{
>> >+	pr_out("Usage: %s link show [DEV/PORT_INDEX]\n", rd->filename);
>> >+	return 0;
>> >+}
>> >+
>> >+static void link_print_caps(struct nlattr **tb)
>> >+{
>> >+	uint64_t caps;
>> >+	uint32_t idx;
>> >+
>> >+	/*
>> >+	 * FIXME: move to indexes when kernel will start exporting them.
>>
>> Not exported yet?
>
>Not yet, I want to minimize the UAPI export from kernel before user-space
>part is accepted.

I don't get it. If you need it in userspace, you should expose it. Why
to wait? What am I missing?

[...]


>> >+		rd->port_idx = port ? :1;
>>
>> "port ? : 1"
>
>Yeah, legal C, the same as (port) ? port : 1
>ihttps://en.wikipedia.org/wiki/%3F:#C


I was referring to the missing " ". I'm a nitpicker :)
