From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC net-next PATCH 1/5] samples/bpf: xdp_tx_iptunnel make use
 of map_data[]
Date: Fri, 19 May 2017 17:45:25 +0200
Message-ID: <591F1315.3010304@iogearbox.net>
References: <149512205297.14733.15729847433404265933.stgit@firesoul> <149512209298.14733.14668513619424960672.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34495 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751326AbdESPpa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 11:45:30 -0400
In-Reply-To: <149512209298.14733.14668513619424960672.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2017 05:41 PM, Jesper Dangaard Brouer wrote:
> There is no reason to use a compile time constant MAX_IPTNL_ENTRIES
> shared between the _user.c and _kern.c, when map_data[].def.max_entries
> can tell us dynamically what the max_entries were of the ELF map that
> the bpf loaded created.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Previous code was perhaps a bit more robust in the sense that the
order of the map wouldn't matter due to MAX_IPTNL_ENTRIES being
shared. Now you rely on it being in slot 1 (map_data[1].def.max_entries)
from "maps" section in ELF.

>   samples/bpf/xdp_tx_iptunnel_common.h |    2 --
>   samples/bpf/xdp_tx_iptunnel_kern.c   |    2 +-
>   samples/bpf/xdp_tx_iptunnel_user.c   |   14 +++++++++-----
>   3 files changed, 10 insertions(+), 8 deletions(-)

Not sure it's worth it given this actually adds more code and makes
it more fragile at the same time. Only point I could see is to demo
usage of map_data[1].def.max_entries for sample code.

Perhaps at the very minimum add a warning comment to xdp_tx_iptunnel_kern.c
that should the code be further extended with additional maps, that
ordering of struct bpf_map_def entries really matters here to not break
the _user.c part.

Other than that, this should be sent as stand-alone "cleanup" ...
