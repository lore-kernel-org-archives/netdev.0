From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Use-after-free in selinux_ip_postroute_compat
Date: Thu, 05 Nov 2015 11:46:46 -0800
Message-ID: <1446752806.4184.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+ZVnfoqeJZ5cOKu70d3N9LuPMeotarKGBx-EHwYrOe-Eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Sasha Levin <sasha.levin@oracle.com>,
	Kees Cook <keescook@google.com>,
	Julien Tinnes <jln@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+ZVnfoqeJZ5cOKu70d3N9LuPMeotarKGBx-EHwYrOe-Eg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-11-05 at 20:36 +0100, Dmitry Vyukov wrote:
> Hello,
> 
> I've updated from bcee19f424a0d8c26ecf2607b73c690802658b29 (Sep 21) to
> 8e483ed1342a4ea45b70f0f33ac54eff7a33d918 (Nov 4) and start seeing the
> following use-after-free reports:
> 

Thanks for your report, I will add a followup to this fix :

commit e446f9dfe17bbaa76a1fe22912636f38be1e1af8
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu Oct 8 05:01:55 2015 -0700

    net: synack packets can be attached to request sockets
    
    selinux needs few changes to accommodate fact that SYNACK messages
    can be attached to a request socket, lacking sk_security pointer
    
    (Only syncookies are still attached to a TCP_LISTEN socket)
    
    Adds a new sk_listener() helper, and use it in selinux and sch_fq
    
    Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Reported by: kernel test robot <ying.huang@linux.intel.com>
    Cc: Paul Moore <paul@paul-moore.com>
    Cc: Stephen Smalley <sds@tycho.nsa.gov>
    Cc: Eric Paris <eparis@parisplace.org>
    Acked-by: Paul Moore <paul@paul-moore.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
