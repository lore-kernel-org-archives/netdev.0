From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH net-next] bpf: fix potential percpu map overcopy to
 user.
Date: Thu, 20 Oct 2016 09:58:09 -0700
Message-ID: <20161020165807.GB97796@ast-mbp.thefacebook.com>
References: <1476636088-9268-1-git-send-email-u9012063@gmail.com>
 <20161019005004.GA87961@ast-mbp.thefacebook.com>
 <CALDO+SaebqahYHn2PU=nk6mYOMjRp+F8PKb3cFaGMv4_xjLwZg@mail.gmail.com>
 <58078E1D.6080108@iogearbox.net>
 <5808EB16.4000103@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: William Tu <u9012063@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36299 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753501AbcJTQ6P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 12:58:15 -0400
Received: by mail-pf0-f195.google.com with SMTP id r16so6058527pfg.3
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 09:58:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5808EB16.4000103@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2016 at 06:04:38PM +0200, Daniel Borkmann wrote:
> 
> diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
> index ee384f0..d4832e8 100644
> --- a/tools/testing/selftests/bpf/test_maps.c
> +++ b/tools/testing/selftests/bpf/test_maps.c
> @@ -25,6 +25,33 @@
> 
>  static int map_flags;
> 
> +static unsigned int num_possible_cpus(void)
> +{
> +	static const char *fcpu = "/sys/devices/system/cpu/possible";
> +	unsigned int val, possible_cpus = 0;
> +	char buff[128];
> +	FILE *fp;
> +
> +	fp = fopen(fcpu, "r");
> +	if (!fp) {
> +		printf("Failed to open %s: '%s'!\n", fcpu, strerror(errno));
> +		exit(1);
> +	}
> +
> +	while (fgets(buff, sizeof(buff), fp)) {
> +		if (sscanf(buff, "%*u-%u", &val) == 1)
> +			possible_cpus = val;
> +	}

looks great to me.
Could you move it into bpf_sys.h or somehow make it common in libbpf
and reuse it in samples/bpf/ ?
Since quite a few samples need this fix as well.
Thanks!
