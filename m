From: subashab@codeaurora.org
Subject: Re: [PATCH] net: rps: fix data stall after hotplug
Date: Tue, 31 Mar 2015 22:02:03 -0000
Message-ID: <667cd94f1b58cc008ddcb91751f90fd7.squirrel@www.codeaurora.org>
References: <b3ecb218932daa656a796cfa6e9e62b9.squirrel@www.codeaurora.org>
    <1426801839.25985.15.camel@edumazet-glaptop2.roam.corp.google.com>
    <1426852239.25985.33.camel@edumazet-glaptop2.roam.corp.google.com>
    <b25a45de2cb43bbcfcaa84634d74533e.squirrel@www.codeaurora.org>
    <744bbefe8859bf667eafc0de02729078.squirrel@www.codeaurora.org>
    <1427149742.25985.84.camel@edumazet-glaptop2.roam.corp.google.com>
    <49d5ac3130df29059f167a0401754c67.squirrel@www.codeaurora.org>
    <6ef597cb521f6c9adf48562c72677415.squirrel@www.codeaurora.org>
    <1427777316.25985.168.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:36127 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752804AbbCaWCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 18:02:04 -0400
In-Reply-To: <1427777316.25985.168.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Listen, I would rather disable RPS on your arch, instead of messing with
> it.
>
> Reset NAPI state as you did is in direct violation of the rules.
>
> Only cpu owning the bit is allowed to reset it.
>

Perhaps my understanding of the code in dev_cpu_callback() is incorrect?
Please correct me if I am wrong.

The poll list is copied from an offline cpu to an online cpu.
Specifically for process_backlog, I was under the impression that
the online cpu tries to reset the state of NAPI of the offline cpu.
The process and input queues are then always copied to the
online cpu.

while (!list_empty(&oldsd->poll_list)) {
	struct napi_struct *napi = list_first_entry(&oldsd->poll_list,
						    struct napi_struct,
							     poll_list);

	list_del_init(&napi->poll_list);
	if (napi->poll == process_backlog)
		napi->state = 0;
	else
		____napi_schedule(sd, napi);
}

My request was to know why it would be incorrect to clear the offline cpu
backlog NAPI state unconditionally.
