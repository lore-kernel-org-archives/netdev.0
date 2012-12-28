From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 01/19] netfilter: move nf_conntrack initialize out of pernet operations
Date: Thu, 27 Dec 2012 22:00:23 -0800
Message-ID: <8738yqiumg.fsf@xmission.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
	<CAFFEFTXT_fkF2pPSxDEEgic80NVWLqBWtFuvs6W9uDUW2aCnqw@mail.gmail.com>
	<87ip7mlr2r.fsf@xmission.com>
	<CAFFEFTU8kxXV2pQ3B_goRs2Y7p2ecZ1YuSKSjfYF_58eD1tDqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gao feng <gaofeng@cn.fujitsu.com>, netfilter-devel@vger.kernel.org,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, pablo@netfilter.org
To: canqun zhang <canqunzhang@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAFFEFTU8kxXV2pQ3B_goRs2Y7p2ecZ1YuSKSjfYF_58eD1tDqw@mail.gmail.com>
	(canqun zhang's message of "Fri, 28 Dec 2012 13:32:29 +0800")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

canqun zhang <canqunzhang@gmail.com> writes:

> yes=EF=BC=8CNetwork namespaces in general can be cleaned up in any or=
der=EF=BC=8Cbut
> when doing /etc/ini.d/iptables restart, the system need cleaning up
> all net namespace,and init_net should be cleanup lastly.init_net is
> the first namespace,other net namespace is copied for it ,and it is
> diuty for Initializing resources,so It in itself is special.

"other net namespaces is copied for it"  I don't have a clue what
you mean by that.  Every network namespace starts out in a default
state not in a copied state.

Nowhere else in the network stack does &init_net have the duty
of initializing or cleaning up resources.

That /etc/init.d/iptables restart removes modules in general is a littl=
e
dubious.  That /etc/init.d/iptables restart removes modules when there
are other existing network namespaces using those modules is down right
dangerous.  Dangerous in the anyone can ssh into the machine way.  I
suspect it has taken 5 years for this bug to show up because it is so
idiotic to remove code that someone else is using.

I won't argue that making it so that &init_net is the last network
namespace to go will solve this problem.  But I can't see how adding
the guarantee that &init_net will always be cleaned up last is a good
long term solution.

Removing the init_net special case gives a simpler mental model, and
less to learn and maintain about network namespaces.

Eric
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
