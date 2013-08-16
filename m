From: Florian Westphal <fw@strlen.de>
Subject: Re: MASQUERADE/SNAT and multiple interfaces with the same IP
Date: Fri, 16 Aug 2013 13:18:26 +0200
Message-ID: <20130816111826.GC5154@breakpoint.cc>
References: <CAKfDRXjXkY--PjXAa1m=As+Vf_1__WBokkTAE5BHg+gxsM9Yxw@mail.gmail.com>
 <20130816110443.GB5154@breakpoint.cc>
 <CAKfDRXgNtPgQjtrSL=oVkws6GB_sTv+h+-_GLVvVvpWoEHBRnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter@vger.kernel.org,
	netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAKfDRXgNtPgQjtrSL=oVkws6GB_sTv+h+-_GLVvVvpWoEHBRnw@mail.gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kristian Evensen <kristian.evensen@gmail.com> wrote:
> I added a pr_info() here to see when this function was called. It is
> triggered when the link goes down, as expected, but not when I just
> change the mark and move the flows to another interface. I still see
> the DESTROY/NEW-behavior though.

Yes, its handled by iptable_nat.c

> > Also, the nat core zaps conntracks when they are sent out on an
> > interface other than the original interface.
> >
> > See nf_nat_oif_changed() in iptable_nat.c
> 
> Thanks for letting me know, I will start looking into this function.
> Does this mean that even when using SNAT, the old mapping is deleted
> and a new created?

No.

> And does this event not notify conntrack?

It generates a destroy event.
