From: Dragos Ilie <dragos.ilie@gmail.com>
Subject: Computations in tc_red.c
Date: Fri, 27 Jul 2012 01:38:20 +0200
Message-ID: <5011D4EC.1090801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:58306 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753226Ab2GZXiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 19:38:25 -0400
Received: by eeil10 with SMTP id l10so509927eei.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 16:38:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a couple of questions about the function tc_red_eval_idle_damping() in iproute2/tc/tc_red.c. Originally, I sent the questions to Alexey Kuznetsov (for several months ago) since he is listed as the author, but did not receive a reply from him. Hence, I am directing my questions to the netdev mailing list.

My understanding is that the tc_red_eval_idle_damping() function pre-computes a set of values in the range 0-31. These values are later used by the kernel function red_calc_qavg_from_idle_time() in include/net/red.h to calculate the average queue size during idle time. The values represent the number of shifts applied to the current average queue size, which is a scaling factor of the form 2^(-n).

In tc_red_eval_idle_damping() the lW constant is defined as

double lW = -log(1.0 - 1.0/(1<<Wlog))/xmit_time

This is equivalent to -log(1.0 - W)/xmit_time, where W is scaled by a
negative power of two (Wlog is computed in tc_red_eval_ ewma()). The
constant is used to choose a time scaling factor called clog. The
condition used in choosing clog is

maxtime/1<<clog < 512

where maxtime = 31/lW. What is the reason for choosing 512 as upper bound?


My second question is about the average queue length computed in kernel function red_calc_qavg_from_idle_time() in include/net/red.h. According to the comment in that
function, the average queue length v->qavg should be adjusted as

v->qavg *= (1-W)^m

The code approximates this function by scaling v->qavg with 2^(-n),
where n was precomputed in c_red_eval_idle_damping(). I have trouble
seeing the connection between the log() function used to compute the
constant lW and the approximation used. I am hoping you can shed some
light on it.

Best regards,
Dragos Ilie
