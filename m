From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip: add udp_csum, udp6_csum_tx, udp6_csum_rx control
 flags to ip l2tp add tunnel
Date: Mon, 2 May 2016 15:19:10 -0700
Message-ID: <20160502151910.3a1f6f3d@xeon-e3>
References: <CAEwTi7SkMrgxpPi-EuC2UDiwv7L0-vdRAhtdAYLgnbnw5H-Eig@mail.gmail.com>
	<FD67CA88-0731-4DD7-AC78-5A4B922810D6@gmail.com>
	<AFE6B2C1-93B5-4782-870D-2C6C81BF6F52@gmail.com>
	<CAEwTi7SyKKh4de6TKYiuypWfOhzOCeD6k2uTLUfCmzQmvsNHWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Wang Shanker <shankerwangmiao@gmail.com>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33647 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755166AbcEBWTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 18:19:06 -0400
Received: by mail-io0-f171.google.com with SMTP id f89so6093040ioi.0
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 15:19:05 -0700 (PDT)
In-Reply-To: <CAEwTi7SyKKh4de6TKYiuypWfOhzOCeD6k2uTLUfCmzQmvsNHWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Apr 2016 15:50:47 +0100
James Chapman <jchapman@katalix.com> wrote:

> Yes, that looks like the problem.
> 
> The comments in l2tp.h which indicate that the csum attributes are u8
> values are wrong. Code in net/l2tp/l2tp_netlink.c accesses these
> attributes using nla_get_flag().
> 
> Please submit a patch to fix l2tp_tunnel_sock_create(). Include good
> change notes and your signed-off-by tag so that it gets reviewed. See
> Documentation/SubmittingPatches if you haven't submitted a kernel
> patch here before.

Thank you for fixing this. James is is correct.
Please format the patch according to the submission guidelines.
For example, checkpatch complains about current patch.

ERROR: code indent should use tabs where possible
#156: FILE: net/l2tp/l2tp_core.c:1379:
+                         ! cfg->udp6_zero_tx_checksums;$

WARNING: please, no spaces at the start of a line
#156: FILE: net/l2tp/l2tp_core.c:1379:
+                         ! cfg->udp6_zero_tx_checksums;$

ERROR: space prohibited after that '!' (ctx:ExW)
#156: FILE: net/l2tp/l2tp_core.c:1379:
+                         ! cfg->udp6_zero_tx_checksums;
                          ^

ERROR: code indent should use tabs where possible
#159: FILE: net/l2tp/l2tp_core.c:1381:
+                         ! cfg->udp6_zero_rx_checksums;$

WARNING: please, no spaces at the start of a line
#159: FILE: net/l2tp/l2tp_core.c:1381:
+                         ! cfg->udp6_zero_rx_checksums;$

ERROR: space prohibited after that '!' (ctx:ExW)
#159: FILE: net/l2tp/l2tp_core.c:1381:
+                         ! cfg->udp6_zero_rx_checksums;
                          ^

ERROR: Missing Signed-off-by: line(s)


I am sorry that maintainers may seem like picky teachers in school
always putting redline around spelling errors, but this is how we work to teach
others how to follow the process.
