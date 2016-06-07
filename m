From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [PATCH net-next 2/2] tcp: add NV congestion control
Date: Tue, 7 Jun 2016 01:04:06 +0000
Message-ID: <D37B5339.19584%brakmo@fb.com>
References: <1464986278-2096156-1-git-send-email-brakmo@fb.com>
 <1464986278-2096156-3-git-send-email-brakmo@fb.com>
 <20160606.160108.1481703166637051807.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kernel Team <Kernel-team@fb.com>,
	"ncardwell@google.com" <ncardwell@google.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"ycheng@google.com" <ycheng@google.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"kennetkl@ifi.uio.no" <kennetkl@ifi.uio.no>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33327 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750788AbcFGBEV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2016 21:04:21 -0400
In-Reply-To: <20160606.160108.1481703166637051807.davem@davemloft.net>
Content-Language: en-US
Content-ID: <D08DF8BCDA89C04C9020DB6AAE61E48F@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/6/16, 4:01 PM, "David Miller" <davem@davemloft.net> wrote:

>From: Lawrence Brakmo <brakmo@fb.com>
>Date: Fri, 3 Jun 2016 13:37:58 -0700
>
>> +module_param(nv_enable, int, 0644);
>> +MODULE_PARM_DESC(nv_enable, "enable NV (congestion avoidance)
>>behavior");
>> +module_param(nv_pad, int, 0644);
>> +MODULE_PARM_DESC(nv_pad, "extra packets above congestion level");
>> +module_param(nv_pad_buffer, int, 0644);
>> +MODULE_PARM_DESC(nv_pad_buffer, "no growth buffer zone");
>> +module_param(nv_reset_period, int, 0644);
>> +MODULE_PARM_DESC(nv_reset_period, "nv_min_rtt reset period (secs)")=
;
>> +module_param(nv_min_cwnd, int, 0644);
>> +MODULE_PARM_DESC(nv_min_cwnd, "NV will not decrease cwnd below this
>>value"
>> +		 " without losses");
>> +module_param(nv_dec_eval_min_calls, int, 0644);
>> +MODULE_PARM_DESC(nv_dec_eval_min_calls, "Wait for this many data
>>points"
>> +		 " before declaring congestion");
>> +module_param(nv_inc_eval_min_calls, int, 0644);
>> +MODULE_PARM_DESC(nv_inc_eval_min_calls, "Wait for this many data
>>points"
>> +		 " before allowing cwnd growth");
>> +module_param(nv_stop_rtt_cnt, int, 0644);
>> +MODULE_PARM_DESC(nv_stop_rtt_cnt, "Wait for this many RTTs before
>>stopping"
>> +		 " cwnd growth");
>> +module_param(nv_ssthresh_eval_min_calls, int, 0644);
>> +MODULE_PARM_DESC(nv_ssthresh_eval_min_calls, "Wait for this many da=
ta
>>points"
>> +		 " before declaring congestion during initial slow-start");
>> +module_param(nv_rtt_min_cnt, int, 0644);
>> +MODULE_PARM_DESC(nv_rtt_min_cnt, "Wait for this many RTTs before
>>declaring"
>> +		 " congestion");
>> +module_param(nv_cong_dec_mult, int, 0644);
>> +MODULE_PARM_DESC(nv_cong_dec_mult, "Congestion decrease factor");
>> +module_param(nv_ssthresh_factor, int, 0644);
>> +MODULE_PARM_DESC(nv_ssthresh_factor, "ssthresh factor");
>> +module_param(nv_rtt_factor, int, 0644);
>> +MODULE_PARM_DESC(nv_rtt_factor, "rtt averaging factor");
>> +module_param(nv_rtt_cnt_dec_delta, int, 0644);
>> +MODULE_PARM_DESC(nv_rtt_cnt_dec_delta, "decrease cwnd for this many
>>RTTs"
>> +		 " every 100 RTTs");
>> +module_param(nv_dec_factor, int, 0644);
>> +MODULE_PARM_DESC(nv_dec_factor, "decrease cwnd every ~192 RTTS by
>>factor/8");
>> +module_param(nv_loss_dec_factor, int, 0644);
>> +MODULE_PARM_DESC(nv_loss_dec_factor, "on loss new cwnd =3D cwnd * t=
his /
>>1024");
>> +module_param(nv_cwnd_growth_rate_neg, int, 0644);
>> +MODULE_PARM_DESC(nv_cwnd_growth_rate_neg, "Applies when current cwn=
d
>>growth"
>> +		 " rate < Reno");
>> +module_param(nv_cwnd_growth_rate_pos, int, 0644);
>> +MODULE_PARM_DESC(nv_cwnd_growth_rate_pos, "Applies when current cwn=
d
>>growth"
>> +		 " rate >=3D Reno");
>> +module_param(nv_min_min_rtt, int, 0644);
>> +MODULE_PARM_DESC(nv_min_min_rtt, "lower bound for ca->nv_min_rtt");
>> +module_param(nv_max_min_rtt, int, 0644);
>> +MODULE_PARM_DESC(nv_max_min_rtt, "upper bound for ca->nv_min_rtt");
>
>That's a disturbingly huge number of module parameters.  Even the firs=
t
>one "nv_enable" is superfluous, just hook up another congestion contro=
l
>algorithm.
>
>Please trim this down to something reasonable.  The more of these you
>have,
>the more of them people will start wanting to use and depend upon, and
>then
>you're stuck with them whether you like it or not.

I will trim them down to something much smaller. My original intent was=
 to
support experimentation, but those interested can use this version of t=
he
patch to play with a larger number of parameters/tunables.

In regards to the parameter =B3nv_enable=B2, its function is to quickly=
 allow
existing NV flows to revert to Reno behavior (by =B3echo 0 >
/sys/module/tcp_nv/parameters/nv_enable=B2). The reason why this may be
necessary, is that under some conditions NV flows competing with more
aggressive flows will perform poorly. People may be more willing to tes=
t
NV if there is a quick and simple way to revert if necessary (without
having to restart the flows).

As to why NV could perform poorly, it has to do with the inherent
unfairness between flows that only decrease their cwnd when there are
losses (congestion control) and flows that decrease their cwnd when the=
y
detect queue buildup (congestion avoidance) unless there is network
support. This is specially true when the RTTs for both types are small
(traffic within a DC), but the unfairness decreases as the RTTs of the
congestion control flows increases.

So, is it okay if I leave the parameter =B3nv_enable=B2 or would you st=
ill
prefer that I remove it?
