From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [RFC PATCH net-next] tcp: add NV congestion control
Date: Mon, 6 Jul 2015 23:01:18 +0000
Message-ID: <D1C055DE.47B1%brakmo@fb.com>
References: <1435886484-1709996-1-git-send-email-brakmo@fb.com>
 <CALx6S35pRq_Z32R3xWTj4PpQJ4YkC-MzxzeYb8+vH=cfTibwcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:11606 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755924AbbGFXBh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2015 19:01:37 -0400
In-Reply-To: <CALx6S35pRq_Z32R3xWTj4PpQJ4YkC-MzxzeYb8+vH=cfTibwcQ@mail.gmail.com>
Content-Language: en-US
Content-ID: <D9862AF719F7774A94232E071B4F03DB@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 7/3/15, 10:10 AM, "Tom Herbert" <tom@herbertland.com> wrote:

>On Thu, Jul 2, 2015 at 6:21 PM, Lawrence Brakmo <brakmo@fb.com> wrote:
>> This is a request for comments.
>>
>> TCP-NV (New Vegas) is a major update to TCP-Vegas. An earlier version of
>> NV was presented at 2010's LPC (slides). It is a delayed based
>> congestion avoidance for the data center. This version has been tested
>> within a 10G rack where the HW RTTs are 20-50us.
>>
>> A description of TCP-NV, including implementation and experimental
>> results, can be found at:
>> 
>>https://urldefense.proofpoint.com/v1/url?u=http://www.brakmo.org/networki
>>ng/tcp-nv/TCPNV.html&k=ZVNjlDMF0FElm4dQtryO4A%3D%3D%0A&r=m30SgjN07T%2FK%2
>>FdV1ZIt1iA%3D%3D%0A&m=vqkRy6FmoxrfPZVJumijB%2B1wrVylIcWDPCz5JB6%2Blp0%3D%
>>0A&s=232c928c0c7acaf211a56119e00288f4cc11cff70beef2159933f7667d59a773
>>
>> The current version includes many module parameters to support
>> experimentation with the parameters.
>>
>>
>> +module_param(nv_pad, int, 0644);
>> +MODULE_PARM_DESC(nv_pad, "extra packets above congestion level");
>> +module_param(nv_reset_period, int, 0644);
>> +MODULE_PARM_DESC(nv_reset_period, "nv_min_rtt reset period (secs)");
>> +module_param(nv_min_cwnd, int, 0644);
>> +MODULE_PARM_DESC(nv_min_cwnd, "NV will not decrease cwnd below this
>>value"
>> +                " without losses");
>> +module_param(nv_dec_eval_min_calls, int, 0644);
>> +MODULE_PARM_DESC(nv_dec_eval_min_calls, "Wait for this many data
>>points "
>> +                "before declaring congestion (< 256)");
>> +module_param(nv_ssthresh_eval_min_calls, int, 0644);
>> +MODULE_PARM_DESC(nv_ssthresh_eval_min_calls, "Wait for this many data
>>points "
>> +                "before declaring congestion during initial
>>slow-start");
>> +module_param(nv_rtt_min_cnt, int, 0644);
>> +MODULE_PARM_DESC(nv_rtt_min_cnt, "Wait for this many RTTs before
>>declaring"
>> +                " congestion (<64)");
>> +module_param(nv_cong_decrease_mult, int, 0644);
>> +MODULE_PARM_DESC(nv_cong_decrease_mult, "Congestion decrease factor");
>> +module_param(nv_ssthresh_factor, int, 0644);
>> +MODULE_PARM_DESC(nv_ssthresh_factor, "ssthresh factor");
>> +module_param(nv_rtt_factor, int, 0644);
>> +MODULE_PARM_DESC(nv_rtt_factor, "rtt averaging factor (0-256)");
>> +module_param(nv_rtt_cnt_inc_delta, int, 0644);
>> +MODULE_PARM_DESC(nv_rtt_cnt_inc_delta, "decrease cwnd for this many
>>RTTs "
>> +                "every 100 RTTs");
>> +module_param(nv_dec_factor, int, 0644);
>> +MODULE_PARM_DESC(nv_dec_factor, "decrease cwnd every ~192 RTTS by
>>factor/8");
>> +module_param(nv_loss_dec_factor, int, 0644);
>> +MODULE_PARM_DESC(nv_loss_dec_factor, "on loss new cwnd = cwnd * this /
>>1024");
>> +module_param(nv_cwnd_growth_factor, int, 0644);
>> +MODULE_PARM_DESC(nv_cwnd_growth_factor, "larger => cwnd grows slower");
>> +
>A lot of module parameters... can these be sysctls?

I think module parameters are less intrusive than sysctls. These
parameters are there for experimentation and expect many of them will be
removed in the future after more testing and experimentation.
