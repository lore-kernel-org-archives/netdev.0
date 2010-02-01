From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: debug: nt_conntrack and KVM crash
Date: Mon, 1 Feb 2010 12:25:24 +0200
Message-ID: <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant>
	 <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
	 <1265019160.2848.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jon Masters <jonathan@jonmasters.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1265019160.2848.14.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 1, 2010 at 12:12 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 01 f=E9vrier 2010 =E0 11:36 +0200, Alexey Dobriyan a =E9crit=
 :
>> On Mon, Feb 1, 2010 at 11:32 AM, Jon Masters <jonathan@jonmasters.or=
g> wrote:
>> > I hacked up a per-namespace version of hashtables (this needs doin=
g
>> > anyway, since the global stuff is just waiting to break)
>>
>> Which ones? Conntrack hashtables are per-netns.
>
> It seems they are, but this is not a complete work :

They are per-netns.

It's not "complete", because right now there is no point in doing more.
nf_conntrack_max was rejected given the absense of per-netns kernel
memory consumption limiting.

> 1) Global settings (shared by all netns)

Only hashtable size which is module parameter and
there is no generic way to limit kernel memory (like beancounters).

> 2) nf_conntrack_cachep is shared, it should be not shared.

There is no need for it to be shared, unless you measured something.

> 3) nf_conntrack_untracked shared by all netns, it should be local.
>
> nf_conntrack_cleanup_net() can block forever because of this.
>
> while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
> =A0 =A0 =A0 =A0schedule();

This is known, yes, thinking on it, as naive way was agreed to suck.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
