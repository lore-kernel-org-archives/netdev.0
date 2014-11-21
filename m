From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] filter: add bpf_optimize_div()
Date: Fri, 21 Nov 2014 10:26:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9F646B@AcuExch.aculab.com>
References: <1416512551-22252-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Alexei Starovoitov <ast@plumgrid.com>
To: 'Denis Kirjanov' <kda@linux-powerpc.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60866 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756976AbaKUK1Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 05:27:16 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10860-02 for <netdev@vger.kernel.org>;
 Fri, 21 Nov 2014 10:27:06 +0000 (GMT)
In-Reply-To: <1416512551-22252-1-git-send-email-kda@linux-powerpc.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov
> optimize_div() found in  mips bpf jit is really usefull
> for other arches. So let's put it in filter.h
...
> +static inline int bpf_optimize_div(u32 *k)
> +{
> +	/* power of 2 divides can be implemented with right shift */
> +	if (!(*k & (*k-1))) {
> +		*k = ilog2(*k);
> +		return 1;
> +	}
> +
> +	return 0;
> +}

If 'k' is a constant then a 'multiply by reciprocal' is likely to
be as fast as the shift - and works for a wider range of values.

On some architectures the ilog2() may itself be expensive.

On x86 the divide might even be faster than the conditional mess
the above generates.

	David
