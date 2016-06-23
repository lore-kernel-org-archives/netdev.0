From: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>
Subject: Re: [PATCH net-next v2 3/4] cgroup: bpf: Add bpf_skb_in_cgroup_proto
Date: Thu, 23 Jun 2016 09:54:49 -0700
Message-ID: <20160623165449.GC82305@kafai-mba.local>
References: <1466630252-3822277-1-git-send-email-kafai@fb.com>
 <1466630252-3822277-4-git-send-email-kafai@fb.com>
 <576BB1AE.5080605@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <kernel-team-b10kYP2dOMg@public.gmane.org>
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <576BB1AE.5080605-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 23, 2016 at 11:53:50AM +0200, Daniel Borkmann wrote:
> >diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> >index 668e079..68753e0 100644
> >--- a/kernel/bpf/verifier.c
> >+++ b/kernel/bpf/verifier.c
> >@@ -1062,6 +1062,10 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
> >  		if (func_id != BPF_FUNC_get_stackid)
> >  			goto error;
> >  		break;
> >+	case BPF_MAP_TYPE_CGROUP_ARRAY:
> >+		if (func_id != BPF_FUNC_skb_in_cgroup)
> >+			goto error;
> >+		break;
>
> I think the BPF_MAP_TYPE_CGROUP_ARRAY case should have been fist here in
> patch 2/4, but with unconditional goto error. And this one only adds the
> 'func_id != BPF_FUNC_skb_in_cgroup' test.
I am not sure I understand.  Can you elaborate? I am probably missing
something here.

>
> >  	default:
> >  		break;
> >  	}
> >@@ -1081,6 +1085,10 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
> >  		if (map->map_type != BPF_MAP_TYPE_STACK_TRACE)
> >  			goto error;
> >  		break;
> >+	case BPF_FUNC_skb_in_cgroup:
> >+		if (map->map_type != BPF_MAP_TYPE_CGROUP_ARRAY)
> >+			goto error;
> >+		break;
> >  	default:
> >  		break;
> >  	}
