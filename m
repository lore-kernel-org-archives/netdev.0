From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: tc ipt action
Date: Sun, 16 Dec 2012 01:26:32 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212160119060.7193@nerf07.vanv.qr>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: vapier@gentoo.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sunday 2012-12-16 00:06, Jan Engelhardt wrote:
>On Saturday 2012-12-15 22:19, Jamal Hadi Salim wrote:
>>
>> Example, the following should work for
>> tc filter add dev eth0 parent ffff: protocol ip u32 match u32 0 0
>> action ipt -j CONNMARK \
>> action mirred egress redirect dev ifb0
>
>If I try that command (substituting ipt->xt and eth0->dummy0,
>ifb0->dummy1), all I get is the dreaded "Invalid argument".
>So the kernel rejected the command, which could indicate that
>userspace construction might have been ok.
>
># tc filter add dev dummy0 parent ffff: protocol ip u32 match u32 0 0 \
>action xt -j CONNMARK action mirred egress redirect dev dummy1
>
>tablename: mangle hook: NF_IP_PRE_ROUTING
>        target:  CONNMARK and 0x0 index 0
>RTNETLINK answers: Invalid argument
>We have an error talking to the kernel
>
>> Pablo, Hasan Chowdhury tells me this broke after iptable 1.4.10
>> Hasan also sent me a small patch to fake "xt" instead of "ipt" - but i think
>> there's more than meets the eye here; some interface we are using to talk to
>> xtables on user space seems to have changed.
>
>What was the last combination that worked?

For added fun, it works even less in iproute2-3.7.0.

commit e4fc4ada3317ea94452576add25981279d705b14
Author: Mike Frysinger <vapier@gentoo.org>
Date:   Thu Nov 8 11:41:17 2012 -0500

    allow pkg-config to be customized
    
    Rather than hard coding `pkg-config`, use ${PKG_CONFIG} so people can
    override it to their specific version (like when cross-compiling).
    
    This is the same way the upstream pkg-config code works.
    
    Signed-off-by: Mike Frysinger <vapier@gentoo.org>


broke it by causing tc/m_xt.so to no longer link against libxtables.so,
leading to:

# tc [above parameters]
tc: symbol lookup error: /usr/lib64/tc//m_xt.so: undefined symbol:
xtables_init_all


(Makefiles being simpler than $other_buildsys? A distant reality!)
