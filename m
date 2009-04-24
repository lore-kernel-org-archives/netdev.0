From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Fri, 24 Apr 2009 20:51:28 +0800
Message-ID: <20090424125128.GA28528@gondor.apana.org.au>
References: <20090415.030213.249634462.davem@davemloft.net> <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1B468.7020605@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57659 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755447AbZDXMvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 08:51:37 -0400
Content-Disposition: inline
In-Reply-To: <49F1B468.7020605@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 24, 2009 at 08:45:28AM -0400, Andrew Gallatin wrote:
>
> This is strange.  I wonder if it might be a cache footprint issue?
> My intentionally weak receiver is an athlon64 x2 "Toledo", and
> has only 512KB L2 cache.  I can re-test with a core-2 based Xeon.
>
> But can you describe your setup in more detail?  What CPU does the
> receiver have? You say the sender is running 2.6.18.  Is this
> a RHEL5 kernel, or a kernel.org kernel?

processor       : 7
vendor_id       : GenuineIntel
cpu family      : 6
model           : 23
model name      : Intel(R) Xeon(R) CPU           E5440  @ 2.83GHz
stepping        : 6
cpu MHz         : 2833.155
cache size      : 6144 KB
physical id     : 1
siblings        : 1
core id         : 3
cpu cores       : 4
apicid          : 7
initial apicid  : 7
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constant_tsc arch_perfmon pebs bts rep_good pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi flexpriority
bogomips        : 5665.85
clflush size    : 64
cache_alignment : 64
address sizes   : 38 bits physical, 48 bits virtual
power management:

It's a RHEL-5 kernel, -128 to be exact.  But I rebooted into
2.6.30-rc1 and it made no difference.  The previous observed
problem with 30-rc1 seems to only affect cxgb3.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
