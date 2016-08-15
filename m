From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 15 Aug 2016 10:35:03 +1000
Message-ID: <20160815103503.2ff7aa58@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Sargun Dhillon <sargun@sargun.me>
To: David Miller <davem@davemloft.net>,
	Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  kernel/bpf/verifier.c

between commit:

  747ea55e4f78 ("bpf: fix bpf_skb_in_cgroup helper naming")

from the net tree and commit:

  60d20f9195b2 ("bpf: Add bpf_current_task_under_cgroup helper")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc kernel/bpf/verifier.c
index daea765d72e6,0cc46f1df358..000000000000
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@@ -1053,7 -1078,8 +1078,8 @@@ static int check_map_func_compatibility
  			goto error;
  		break;
  	case BPF_MAP_TYPE_CGROUP_ARRAY:
- 		if (func_id != BPF_FUNC_skb_under_cgroup)
 -		if (func_id != BPF_FUNC_skb_in_cgroup &&
++		if (func_id != BPF_FUNC_skb_under_cgroup &&
+ 		    func_id != BPF_FUNC_current_task_under_cgroup)
  			goto error;
  		break;
  	default:
@@@ -1075,7 -1101,8 +1101,8 @@@
  		if (map->map_type != BPF_MAP_TYPE_STACK_TRACE)
  			goto error;
  		break;
+ 	case BPF_FUNC_current_task_under_cgroup:
 -	case BPF_FUNC_skb_in_cgroup:
 +	case BPF_FUNC_skb_under_cgroup:
  		if (map->map_type != BPF_MAP_TYPE_CGROUP_ARRAY)
  			goto error;
  		break;
