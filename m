From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -master] f_bpf: fix filling of handle when no
 further arg is provided
Date: Mon, 23 May 2016 16:15:08 -0700
Message-ID: <20160523161508.5523fe83@xeon-e3>
References: <55bce23c05c03def46a6b5fd385766bcd5351dd7.1463565059.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34146 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbcEWXO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 19:14:56 -0400
Received: by mail-pa0-f45.google.com with SMTP id qo8so72059pab.1
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 16:14:55 -0700 (PDT)
In-Reply-To: <55bce23c05c03def46a6b5fd385766bcd5351dd7.1463565059.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 May 2016 11:58:41 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> We need to fill handle when provided by the user, even if no further
> argument is provided. Thus, move the test for arg to the correct location,
> so that it works correctly:
> 
>   # tc filter show dev foo egress
>   filter protocol all pref 1 bpf
>   filter protocol all pref 1 bpf handle 0x1 bpf.o:[classifier] direct-action
>   filter protocol all pref 1 bpf handle 0x2 bpf.o:[classifier] direct-action
>   # tc filter del dev foo egress prio 1 handle 2 bpf
>   # tc filter show dev foo egress
>   filter protocol all pref 1 bpf
>   filter protocol all pref 1 bpf handle 0x1 bpf.o:[classifier] direct-action
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied
