From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH iproute2 -next v2 4/5] {f,m}_bpf: allow updates on program
 arrays
Date: Thu, 26 Nov 2015 16:19:29 +0100
Message-ID: <1448551169.889784.450810993.378A2FDF@webmail.messagingengine.com>
References: <cover.1448547199.git.daniel@iogearbox.net>
 <552a9be16fb84dadc8333414d1b13a27622084d9.1448547199.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:55480 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752423AbbKZPTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 10:19:30 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 8FD9A20A96
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 10:19:29 -0500 (EST)
In-Reply-To: <552a9be16fb84dadc8333414d1b13a27622084d9.1448547199.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 26, 2015, at 15:38, Daniel Borkmann wrote:
> +static int bpf_mnt_fs(const char *target)
> +{
> +       bool bind_done = false;
> +
> +       while (mount("", target, "none", MS_PRIVATE | MS_REC, NULL)) {
> +               if (errno != EINVAL || bind_done) {
> +                       fprintf(stderr, "mount --make-private %s failed:
> %s\n",
> +                               target, strerror(errno));
> +                       return -1;
> +               }
> +
> +               if (mount(target, target, "none", MS_BIND, NULL)) {
> +                       fprintf(stderr, "mount --bind %s %s failed:
> %s\n",
> +                               target, target, strerror(errno));
> +                       return -1;
> +               }
> +
> +               bind_done = true;
> +       }

Why does user space actually still have to deal with setting the mount
point private? Isn't this handled by the kernel?

> +       if (mount("bpf", target, "bpf", 0, NULL)) {
> +               fprintf(stderr, "mount -t bpf bpf %s failed: %s\n",
> +                       target, strerror(errno));
> +               return -1;
> +       }

Shouldn't this be just enough?

> +       return 0;
> +}

Thanks,
Hannes
