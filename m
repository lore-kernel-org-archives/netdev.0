From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net PATCH] bpf: remove SK_REDIRECT from UAPI
Date: Wed, 1 Nov 2017 09:26:21 +0100
Message-ID: <20171101082621.GC1977@nanopsycho.orion>
References: <20171101021731.10955.49498.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:54730 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751721AbdKAI0X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 04:26:23 -0400
Received: by mail-wm0-f68.google.com with SMTP id r68so3361546wmr.3
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 01:26:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171101021731.10955.49498.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 01, 2017 at 03:17:31AM CET, john.fastabend@gmail.com wrote:
>Now that SK_REDIRECT is no longer a valid return code. Remove it
>from the UAPI completely. Then do a namespace remapping internal
>to sockmap so SK_REDIRECT is no longer externally visible.
>
>Patchs primary change is to do a namechange from SK_REDIRECT to
>__SK_REDIRECT
>
>Reported-by: Alexei Starovoitov <ast@kernel.org>
>Signed-off-by: John Fastabend <john.fastabend@gmail.com>
>---
> include/uapi/linux/bpf.h       |    1 -
> kernel/bpf/sockmap.c           |   16 ++++++++++++----
> tools/include/uapi/linux/bpf.h |    3 +--
> 3 files changed, 13 insertions(+), 7 deletions(-)
>
>diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
>index 0d7948c..7bf4c75 100644
>--- a/include/uapi/linux/bpf.h
>+++ b/include/uapi/linux/bpf.h
>@@ -788,7 +788,6 @@ struct xdp_md {
> enum sk_action {
> 	SK_DROP = 0,
> 	SK_PASS,
>-	SK_REDIRECT,

Is it really ok to do uapi changes like this?
