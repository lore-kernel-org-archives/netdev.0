From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc2-mm1 - several bugs and a crash
Date: Wed, 20 Feb 2008 22:50:09 +0100
Message-ID: <47BCA091.80009@trash.net>
References: <20080216002522.9c4bd0fb.akpm@linux-foundation.org> <47BC982C.7050402@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <47BC982C.7050402@imap.cc>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tilman Schmidt wrote:
> Still, X came up fine, I could log in (Gnome feeling subjectively
> a bit sluggish), call up a web page from the Internet in Firefox,
> and start perusing the logs, when the whole system froze: neither
> mouse nor keyboard would react anymore, and only the Wind^Wreset
> button would put me back in control. After rebooting into the
> previous, non-mm kernel I found this in the syslog:
>
> Feb 20 17:22:40 xenon kernel: [   48.180297] BUG: using smp_processor_id() in preemptible [00000000] code: ntpdate/3562
> Feb 20 17:22:40 xenon kernel: [   48.180297] caller is __nf_conntrack_find+0x9b/0xeb [nf_conntrack]
> Feb 20 17:22:40 xenon kernel: [   48.180297] Pid: 3562, comm: ntpdate Not tainted 2.6.25-rc2-mm1-testing #1
> Feb 20 17:22:40 xenon kernel: [   48.180297]  [<c02015b9>] debug_smp_processor_id+0x99/0xb0
> Feb 20 17:22:40 xenon kernel: [   48.180297]  [<fac643a7>] __nf_conntrack_find+0x9b/0xeb [nf_conntrack]

I guess the cause for this is a combination of preemtible
RCU and conntrack using RCU since 2.6.25-rc. Using
NF_CT_STAT_INC_ATOMIC should fix it, but I'd prefer
to have a fix that doesn't increase overhead when regular
RCU is used.

I'll see if I can find a better way to fix this tommorrow.

