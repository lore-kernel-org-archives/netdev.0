From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: bpf pointer alignment validation
Date: Mon, 8 May 2017 10:30:20 -0700
Message-ID: <20170508173019.fl4poj6fee5ty5f3@ast-mbp.dhcp.thefacebook.com>
References: <20170505.162044.2097924822206705957.davem@davemloft.net>
 <20170505.224709.1156323937148435706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33149 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754638AbdEHRaX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 13:30:23 -0400
Received: by mail-pg0-f41.google.com with SMTP id u187so30361422pgb.0
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 10:30:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170505.224709.1156323937148435706.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 05, 2017 at 10:47:09PM -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 05 May 2017 16:20:44 -0400 (EDT)
> 
> > Anyways, I'll play with this design and see what happens...
> > Feedback is of course welcome.
> 
> Here is a prototype that works for me with test_pkt_access.c,
> which otherwise won't load on sparc.

the approach looks good.

> +static u32 calc_align(u32 imm)
> +{
> +	u32 align = 1;
> +
> +	if (!imm)
> +		return 1U << 31;
> +
> +	while (!(imm & 1)) {
> +		imm >>= 1;
> +		align <<= 1;
> +	}
> +	return align;
> +}

who about
static u32 calc_align(u32 n)
{
	if (!n)
		return 1U << 31;
        return n - ((n - 1) & n);
}
instead?
