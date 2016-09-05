From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3 3/6] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Mon, 05 Sep 2016 10:29:57 -0700
Message-ID: <1473096597.1992.2.camel@perches.com>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
         <1472241532-11682-4-git-send-email-daniel@zonque.org>
         <20160827000819.GB29480@ast-mbp.thefacebook.com>
         <4799c1ce-4cb6-0148-26ce-8b6a8ac2a0eb@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me
To: Daniel Mack <daniel@zonque.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0204.hostedemail.com ([216.40.44.204]:49765 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S936118AbcIERaE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 13:30:04 -0400
In-Reply-To: <4799c1ce-4cb6-0148-26ce-8b6a8ac2a0eb@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-05 at 14:56 +0200, Daniel Mack wrote:
> On 08/27/2016 02:08 AM, Alexei Starovoitov wrote:
[]
> > +	switch (attr->attach_type) {
> > +	case BPF_ATTACH_TYPE_CGROUP_INET_INGRESS:
> > +	case BPF_ATTACH_TYPE_CGROUP_INET_EGRESS: {
> > +		struct cgroup *cgrp;
> > +
> > +		prog = bpf_prog_get_type(attr->attach_bpf_fd,
> > +					 BPF_PROG_TYPE_CGROUP_SOCKET_FILTER);
> > +		if (IS_ERR(prog))
> > +			return PTR_ERR(prog);
> > +
> > +		cgrp = cgroup_get_from_fd(attr->target_fd);
> > +		if (IS_ERR(cgrp)) {
> > +			bpf_prog_put(prog);
> > +			return PTR_ERR(cgrp);
> > +		}
> > +
> > +		cgroup_bpf_update(cgrp, prog, attr->attach_type);
> > +		cgroup_put(cgrp);
> > +
> > +		break;
> > +	}
> this } formatting style is confusing. The above } looks
> like it matches 'switch () {'.
> May be move 'struct cgroup *cgrp' to the top to avoid that?

This style of case statements that declare local variables
with an open brace after the case statement

	switch (bar) {
	[cases...]
	case foo: {
		local declarations;

		code...
	}
	[cases...]
	}

is used quite frequently in the kernel.
I think it's fine as is.
