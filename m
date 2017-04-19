From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: __sk_buff.data_end
Date: Thu, 20 Apr 2017 01:51:55 +0200
Message-ID: <58F7F81B.8040901@iogearbox.net>
References: <1492637460.22185.6.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54735 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934865AbdDSXwL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 19:52:11 -0400
In-Reply-To: <1492637460.22185.6.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2017 11:31 PM, Johannes Berg wrote:
> Hi Alexei, Daniel,
>
> I'm looking at adding the __wifi_sk_buff I talked about, and I notice
> that it uses CB space to store data_end. Unfortunately, in a lot of
> cases, we don't have any CB space to spare in wifi.
>
> Is there any way to generate a series of instructions that instead does
> the necessary calculations? I don't actually *see* such a way, because
> I don't see how I could have a scratch register or scratch stack space,
> but perhaps there's a way to do it?

One option would be, similarly as in bpf_prog_run_save_cb(), to just
save / restore _only_ the data_end pointer portion for this. Calculating
this inline via bpf_convert_ctx_access() would indeed need one more
reg than just the dst reg available in order to perform the data_end
calculation only as BPF insns.
