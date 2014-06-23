From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 14/17] MIPS: bpf: Prevent kernel fall over for >=32bit
 shifts
Date: Mon, 23 Jun 2014 09:44:31 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726096C@AcuExch.aculab.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
 <1403516340-22997-15-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Markos Chandras' <markos.chandras@imgtec.com>,
	"linux-mips@linux-mips.org" <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33140 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751739AbaFWJpF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:45:05 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 29150-09 for <netdev@vger.kernel.org>;
 Mon, 23 Jun 2014 10:44:55 +0100 (BST)
In-Reply-To: <1403516340-22997-15-git-send-email-markos.chandras@imgtec.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markos Chandras
> Remove BUG_ON() if the shift immediate is >=32 to avoid
> kernel crashes due to malicious user input. Since the micro-assembler
> will not allow an immediate greater or equal to 32, we will use the
> maximum value which is 31. This will do the correct thing on either 32-
> or 64-bit cores since no 64-bit instructions are being used in JIT.

I'm not sure that bounding the shift to 31 bits 'is the correct thing'.
I'd have thought that emulating the large shift or masking the shift
to 5 bits are equally 'correct'.

...
>  {
>  	/* sa is 5-bits long */
> -	BUG_ON(sa >= BIT(5));
> +	if (sa >= BIT(5))
> +		sa = BIT(5) - 1;
>  	emit_instr(ctx, sll, dst, src, sa);
...

	David
