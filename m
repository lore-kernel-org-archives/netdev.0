From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] bpf: fix verifier
Date: Wed, 12 Aug 2015 15:49:36 +0200
Message-ID: <20150812134936.GH2183@nanopsycho.orion>
References: <1439365174-4285-1-git-send-email-weichunc@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ast@plumgrid.com,
	xiakaixu@huawei.com
To: Wei-Chun Chao <weichunc@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:32876 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbbHLNtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 09:49:39 -0400
Received: by wijp15 with SMTP id p15so218660294wij.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 06:49:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1439365174-4285-1-git-send-email-weichunc@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I would expect better subject, perhaps something like:
"fix array boundary in check_map_func_compatibility"


Wed, Aug 12, 2015 at 09:39:34AM CEST, weichunc@plumgrid.com wrote:
>Wrong array boundary is used.
>
>Fixes: 35578d798400 bpf: Implement function bpf_perf_event_read())
>Cc: Kaixu Xia <xiakaixu@huawei.com>
>Cc: Alexei Starovoitov <ast@plumgrid.com>
>Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>
>---
> kernel/bpf/verifier.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
>index 48e1c71..ed12e38 100644
>--- a/kernel/bpf/verifier.c
>+++ b/kernel/bpf/verifier.c
>@@ -853,7 +853,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
> 	if (!map)
> 		return 0;
> 
>-	for (i = 0; i <= ARRAY_SIZE(func_limit); i++) {
>+	for (i = 0; i < ARRAY_SIZE(func_limit); i++) {
> 		bool_map = (map->map_type == func_limit[i].map_type);
> 		bool_func = (func_id == func_limit[i].func_id);
> 		/* only when map & func pair match it can continue.
>-- 
>1.9.1
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
