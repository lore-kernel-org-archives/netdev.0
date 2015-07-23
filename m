From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 iproute2] tc: fix bpf compilation with old glibc
Date: Thu, 23 Jul 2015 14:50:27 -0700
Message-ID: <20150723215026.GB31886@Alexeis-MacBook-Pro.local>
References: <20150722094702.2eb3c0ea@urahara>
 <1437635861-19157-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:35749 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753642AbbGWVua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 17:50:30 -0400
Received: by ykdu72 with SMTP id u72so4991790ykd.2
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 14:50:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437635861-19157-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 23, 2015 at 09:17:41AM +0200, Nicolas Dichtel wrote:
> Error was:
> f_bpf.o: In function `bpf_parse_opt':
> f_bpf.c:(.text+0x88f): undefined reference to `secure_getenv'
> m_bpf.o: In function `parse_bpf':
> m_bpf.c:(.text+0x587): undefined reference to `secure_getenv'
> collect2: error: ld returned 1 exit status
> 
> There is no special reason to use the secure version of getenv, thus let's
> simply use getenv().
> 
> CC: Daniel Borkmann <daniel@iogearbox.net>
> Fixes: 88eea5395483 ("tc: {f,m}_bpf: allow to retrieve uds path from env")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> v2: rework the fix to use getenv() instead of secure_getenv()

had the same workaround locally.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
