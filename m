From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH v2 net-next 0/2] BPF and OVS extensions
Date: Tue, 17 Sep 2013 09:40:20 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B733F@saturn3.aculab.com>
References: <1379386119-4157-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "Alexei Starovoitov" <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Eric Dumazet" <edumazet@google.com>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	"James Morris" <jmorris@namei.org>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"Ingo Molnar" <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	"Daniel Borkmann" <dborkman@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Xi Wang" <xi.wang@gmail.com>,
	"David Howells" <dhowells@redhat.com>,
	"Cong Wang" <xiyou.wangcong@gmail.com>,
	"Jesse Gross" <jesse@nicira.com>,
	"Pravin B Shelar" <pshelar@nicira.com>,
	"Ben Pfaff" <blp@nicira.com>, "Thomas Graf" <tgraf@suug.ch>,
	<dev@openvswitch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39959 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751434Ab3IQIlk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 04:41:40 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01922-04 for <netdev@vger.kernel.org>;
 Tue, 17 Sep 2013 09:41:38 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1379386119-4157-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Patch 1/2: generic BPF extension
> Original A and X 32-bit BPF registers are replaced with ten 64-bit registers.
> bpf opcode encoding kept the same. load/store were generalized to access stack,
> bpf_tables and bpf_context.
> BPF program interfaces to outside world via tables that it can read and write,
> and via bpf_context which is in/out blob of data.
> Other kernel components can provide callbacks to tailor BPF to specific needs.

As has been recently pointed out on some of the NetBSD lists
one of the points about BPF is that the filters are deterministic
and easily proven to both terminate and have no unwanted side effects.

The functionality you are proposing breaks both of these assumptions.

It is understood that parsing IPv6 headers is currently impossible
(needs loops of some form) but a specific helper instruction is
probably a better solution.

What you seem to be proposing is a completely different beast,
so you should call it something else - it isn't BPF.

Whether the Linux kernel needs a (another?) byte code interpreter
is a separate issue.

	David
