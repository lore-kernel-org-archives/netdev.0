From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][IPv6] separation xfrm_lookup from ip6_dst_lookup
Date: Tue, 03 Aug 2004 02:00:15 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803.020015.44364045.yoshfuji@linux-ipv6.org>
References: <20040730171205.114f22ba.kazunori@miyazawa.org>
	<20040801195135.16734846.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040801195135.16734846.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040801195135.16734846.davem@redhat.com> (at Sun, 1 Aug 2004 19:51:35 -0700), "David S. Miller" <davem@redhat.com> says:

> On Fri, 30 Jul 2004 17:12:05 +0900
> Kazunori Miyazawa <kazunori@miyazawa.org> wrote:
> 
> > I consider copying flowi(fl_rt) uses too much stack at the moment.
> > I'll re-send the fixed patch again.
> 
> I agree, and let's defer this patch until we
> resolve that.

Is the overhead for allocating memory okay?
Or, do we allcoate some per-cpu memory while ipv6.o initalization phase?
(check: lock? preemption?)
Or, will we allocate fl (and fl_rt) per sock{} (ipv6_pinfo{})?
(ditto.)

We have similar stack usage in other codes, and 
I would fix them at the same time.


Another question just for future reference: 
how many bytes (approx.) do we accept on stack?

Note: sizeof(struct flowi) is 72 bytes (on i386)

--yoshfuji
