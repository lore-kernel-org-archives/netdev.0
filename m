From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Fri, 06 Mar 2015 18:54:25 +0100
Message-ID: <54F9E9D1.5080402@iogearbox.net>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com> <54F77336.7040006@plumgrid.com> <20150305103715.GA3432@morgoth.brq.redhat.com> <54F889EB.7000203@plumgrid.com> <54F8B680.4050307@iogearbox.net> <20150306140233.GD25656@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>, guy@alum.mit.edu,
	atzm@stratosphere.co.jp
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45577 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061AbbCFRyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 12:54:32 -0500
In-Reply-To: <20150306140233.GD25656@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2015 03:02 PM, Michal Kubecek wrote:
> On Thu, Mar 05, 2015 at 09:03:12PM +0100, Daniel Borkmann wrote:
>> On 03/05/2015 05:52 PM, Alexei Starovoitov wrote:
>>
>>> At this point I think it's up to Dave to decide whether we need
>>> this patch (after fixing the issue pointed by Denis) or not.
>>> imo there is a benefit of giving programs more visibility into
>>> skb metadata.
>>
>> I'm not really a big fan of it, but given we added commit a0cdfcf39362
>> ("packet: deliver VLAN TPID to userspace") to packet sockets ...
>
> IMHO the motivation here was not to allow filtering by TPID but because
> without it, libpcap and its users had no chance to get this information
> for packets captured on devices with Rx VLAN offloading so that e.g.
> "tcpdump -e" was showing (guessed) TPID of 0x8100 for all of them, no
> matter what the actual TPID was.

I believe you are referring to VLAN_TPID() in libpcap : So on newer
kernels that indicate TP_STATUS_VLAN_TPID_VALID, it should provide
you the correct TPID via packet socket when offloaded, otherwise it
only hard-codes ETH_P_8021Q in any case.
