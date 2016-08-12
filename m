From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v4 2/3] bpf: Add bpf_current_task_under_cgroup
 helper
Date: Thu, 11 Aug 2016 21:48:20 -0700
Message-ID: <20160812044818.GA39190@ast-mbp.thefacebook.com>
References: <20160812031454.GA2075@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, tj@kernel.org
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32874 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbcHLEs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 00:48:26 -0400
Received: by mail-pf0-f193.google.com with SMTP id i6so864850pfe.0
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 21:48:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160812031454.GA2075@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 11, 2016 at 08:14:56PM -0700, Sargun Dhillon wrote:
> This adds a bpf helper that's similar to the skb_in_cgroup helper to check
> whether the probe is currently executing in the context of a specific
> subset of the cgroupsv2 hierarchy. It does this based on membership test
> for a cgroup arraymap. It is invalid to call this in an interrupt, and
> it'll return an error. The helper is primarily to be used in debugging
> activities for containers, where you may have multiple programs running in
> a given top-level "container".
> 
> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Tejun Heo <tj@kernel.org>
> ---
> +	/**
> +	 * bpf_current_task_under_cgroup(map, index) - Check cgroup2 membership of current task
> +	 * @map: pointer to bpf_map in BPF_MAP_TYPE_CGROUP_ARRAY type
> +	 * @index: index of the cgroup in the bpf_map
> +	 * Return:
> +	 *   == 0 current failed the cgroup2 descendant test
> +	 *   == 1 current succeeded the cgroup2 descendant test
> +	 *    < 0 error
> +	 */
> +	BPF_FUNC_current_task_under_cgroup,
..
>  	case BPF_MAP_TYPE_CGROUP_ARRAY:
> -		if (func_id != BPF_FUNC_skb_in_cgroup)
> +		if (func_id != BPF_FUNC_skb_in_cgroup &&
> +		    func_id != BPF_FUNC_current_task_under_cgroup)
>  			goto error;
...
> +	case BPF_FUNC_current_task_under_cgroup:
>  	case BPF_FUNC_skb_in_cgroup:

Tejun,
do you feel strongly about 'under' ?
It just looks inconsistent vs existing skb_in_cgroup...
"in cgroup" - 4k google hits
"under cgroup" - 2k google hits
