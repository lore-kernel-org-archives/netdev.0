From: Tejun Heo <htejun@fb.com>
Subject: Re: [PATCH v2 3/6] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Wed, 24 Aug 2016 18:14:36 -0400
Message-ID: <20160824221435.GB13455@htj.duckdns.org>
References: <1472070263-29988-1-git-send-email-daniel@zonque.org>
 <1472070263-29988-4-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <daniel@iogearbox.net>, <ast@fb.com>, <davem@davemloft.net>,
        <kafai@fb.com>, <fw@strlen.de>, <pablo@netfilter.org>,
        <harald@redhat.com>, <netdev@vger.kernel.org>, <sargun@sargun.me>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:44534 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755675AbcHXWPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 18:15:05 -0400
Content-Disposition: inline
In-Reply-To: <1472070263-29988-4-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Aug 24, 2016 at 10:24:20PM +0200, Daniel Mack wrote:
>  SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
>  {
>  	union bpf_attr attr = {};
> @@ -888,6 +957,16 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
>  	case BPF_OBJ_GET:
>  		err = bpf_obj_get(&attr);
>  		break;
> +
> +#ifdef CONFIG_CGROUP_BPF
> +	case BPF_PROG_ATTACH:
> +		err = bpf_prog_attach(&attr);
> +		break;
> +	case BPF_PROG_DETACH:
> +		err = bpf_prog_detach(&attr);
> +		break;
> +#endif

So, this is one thing I haven't realized while pushing for "just embed
it in cgroup".  Breaking it out to a separate controller allows using
its own locking instead of having to piggyback on cgroup_mutex.  That
said, as long as cgroup_mutex is not nested inside some inner mutex,
this shouldn't be a problem.  I still think the embedding is fine and
whether we make it an implicit controller or not doesn't affect
userland API at all, so it's an implementation detail that we can
change later if necessary.

Thanks.

-- 
tejun
