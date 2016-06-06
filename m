From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] tcp: add NV congestion control
Date: Mon, 06 Jun 2016 16:01:08 -0700 (PDT)
Message-ID: <20160606.160108.1481703166637051807.davem@davemloft.net>
References: <1464986278-2096156-1-git-send-email-brakmo@fb.com>
	<1464986278-2096156-3-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, ncardwell@google.com,
	eric.dumazet@gmail.com, ycheng@google.com,
	stephen@networkplumber.org, kennetkl@ifi.uio.no
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47682 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbcFFXBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 19:01:10 -0400
In-Reply-To: <1464986278-2096156-3-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Fri, 3 Jun 2016 13:37:58 -0700

> +module_param(nv_enable, int, 0644);
> +MODULE_PARM_DESC(nv_enable, "enable NV (congestion avoidance) behavior");
> +module_param(nv_pad, int, 0644);
> +MODULE_PARM_DESC(nv_pad, "extra packets above congestion level");
> +module_param(nv_pad_buffer, int, 0644);
> +MODULE_PARM_DESC(nv_pad_buffer, "no growth buffer zone");
> +module_param(nv_reset_period, int, 0644);
> +MODULE_PARM_DESC(nv_reset_period, "nv_min_rtt reset period (secs)");
> +module_param(nv_min_cwnd, int, 0644);
> +MODULE_PARM_DESC(nv_min_cwnd, "NV will not decrease cwnd below this value"
> +		 " without losses");
> +module_param(nv_dec_eval_min_calls, int, 0644);
> +MODULE_PARM_DESC(nv_dec_eval_min_calls, "Wait for this many data points"
> +		 " before declaring congestion");
> +module_param(nv_inc_eval_min_calls, int, 0644);
> +MODULE_PARM_DESC(nv_inc_eval_min_calls, "Wait for this many data points"
> +		 " before allowing cwnd growth");
> +module_param(nv_stop_rtt_cnt, int, 0644);
> +MODULE_PARM_DESC(nv_stop_rtt_cnt, "Wait for this many RTTs before stopping"
> +		 " cwnd growth");
> +module_param(nv_ssthresh_eval_min_calls, int, 0644);
> +MODULE_PARM_DESC(nv_ssthresh_eval_min_calls, "Wait for this many data points"
> +		 " before declaring congestion during initial slow-start");
> +module_param(nv_rtt_min_cnt, int, 0644);
> +MODULE_PARM_DESC(nv_rtt_min_cnt, "Wait for this many RTTs before declaring"
> +		 " congestion");
> +module_param(nv_cong_dec_mult, int, 0644);
> +MODULE_PARM_DESC(nv_cong_dec_mult, "Congestion decrease factor");
> +module_param(nv_ssthresh_factor, int, 0644);
> +MODULE_PARM_DESC(nv_ssthresh_factor, "ssthresh factor");
> +module_param(nv_rtt_factor, int, 0644);
> +MODULE_PARM_DESC(nv_rtt_factor, "rtt averaging factor");
> +module_param(nv_rtt_cnt_dec_delta, int, 0644);
> +MODULE_PARM_DESC(nv_rtt_cnt_dec_delta, "decrease cwnd for this many RTTs"
> +		 " every 100 RTTs");
> +module_param(nv_dec_factor, int, 0644);
> +MODULE_PARM_DESC(nv_dec_factor, "decrease cwnd every ~192 RTTS by factor/8");
> +module_param(nv_loss_dec_factor, int, 0644);
> +MODULE_PARM_DESC(nv_loss_dec_factor, "on loss new cwnd = cwnd * this / 1024");
> +module_param(nv_cwnd_growth_rate_neg, int, 0644);
> +MODULE_PARM_DESC(nv_cwnd_growth_rate_neg, "Applies when current cwnd growth"
> +		 " rate < Reno");
> +module_param(nv_cwnd_growth_rate_pos, int, 0644);
> +MODULE_PARM_DESC(nv_cwnd_growth_rate_pos, "Applies when current cwnd growth"
> +		 " rate >= Reno");
> +module_param(nv_min_min_rtt, int, 0644);
> +MODULE_PARM_DESC(nv_min_min_rtt, "lower bound for ca->nv_min_rtt");
> +module_param(nv_max_min_rtt, int, 0644);
> +MODULE_PARM_DESC(nv_max_min_rtt, "upper bound for ca->nv_min_rtt");

That's a disturbingly huge number of module parameters.  Even the first
one "nv_enable" is superfluous, just hook up another congestion control
algorithm.

Please trim this down to something reasonable.  The more of these you have,
the more of them people will start wanting to use and depend upon, and then
you're stuck with them whether you like it or not.
