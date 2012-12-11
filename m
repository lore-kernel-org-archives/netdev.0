From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Tue, 11 Dec 2012 15:12:31 -0800
Message-ID: <20121211151231.0272015b@nehalam.linuxnetplumber.net>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<87mwyi9h1x.fsf@xmission.com>
	<alpine.OSX.2.00.1212111432430.78903@animac.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Michael Richardson <mcr@sandelman.ca>, netdev@vger.kernel.org,
	tcpdump-workers@lists.tcpdump.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: ani@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52534 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754006Ab2LKXSB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2012 18:18:01 -0500
In-Reply-To: <alpine.OSX.2.00.1212111432430.78903@animac.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Dec 2012 14:36:33 -0800 (PST)
Ani Sinha <ani@aristanetworks.com> wrote:

> >
> > It is possible to test for the presence of support of the new vlan bpf
> > extensions by attempting to load a filter that uses them.  As only valid
> > filters can be loaded, old kernels that do not support filtering of vlan
> > tags will fail to load the a test filter with uses them.
> 
> Unfortunately I do not see this. The sk_chk_filter() does not have a
> default in the case statement and the check will not detect an unknown
> instruction. It will fail when the filter is run and as far as I can see,
> the packet will be dropped. Something like this might help?
> 
> diff --git a/net/core/filter.c b/net/core/filter.c
> index c23543c..96338aa 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -548,6 +548,8 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>  			return -EINVAL;
>  		/* Some instructions need special checks */
>  		switch (code) {
> +		/* for unknown instruction, return EINVAL */
> +		default : return -EINVAL;
>  		case BPF_S_ALU_DIV_K:
>  			/* check for division by zero */
>  			if (ftest->k == 0)

Did you test this? I think it will blow up for some existing instructions
like BPF_S_ALU_XOR_X or any of the other non-special instructions.

Also it is not formatted correctly for the kernel programming style.

ERROR: space prohibited before that ':' (ctx:WxW)
#86: FILE: net/core/filter.c:552:
+		default : return -EINVAL;
 		        ^
