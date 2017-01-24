From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Mon, 23 Jan 2017 19:31:58 -0700
Message-ID: <678f4d6f-e2f8-eb37-207a-c77269507f9d@cumulusnetworks.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <20170124020950.GA72992@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35390 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750704AbdAXCcA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 21:32:00 -0500
Received: by mail-pf0-f178.google.com with SMTP id f144so45963062pfa.2
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 18:32:00 -0800 (PST)
In-Reply-To: <20170124020950.GA72992@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/17 7:09 PM, Alexei Starovoitov wrote:
>> +	 */
>> +	if (current->nsproxy->net_ns != &init_net)
>> +		return -EINVAL;
> 
> this restriction I actually don't mind, since it indeed can be
> relaxed later, but please make it proper with net_eq()
> 

I do mind. Why have different restrictions for the skb and sk filters?

I have already shown that ip can alleviate the management aspects of the implementation -- just like ip netns does.
