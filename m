From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] net: introduce SO_INCOMING_CPU
Date: Fri, 14 Nov 2014 14:58:32 -0800
Message-ID: <1416005912.17262.76.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415393472.13896.119.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHO5Pa0OGtgbUp4R287jbK2SFSpVUoXWCJybvHTFsGyCLynqLg@mail.gmail.com>
	 <CALCETrXmCWSoeQLC3WCqMf_sehGVE9KTbTGmsA77ZN84B-V24Q@mail.gmail.com>
	 <1415993614.17262.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_DyUCxE6BqL_xXcqKPUDu7b3jLShV+AL6L+gCzJLriPg@mail.gmail.com>
	 <CALCETrUuChgxXcNrKjYzpe1ry0hx3kf19EfAbY1N1YnG7NFZUw@mail.gmail.com>
	 <CA+mtBx_tNW_Bz0hovZ90XxcLK6pL8d6RX=v5Rg8utfKkaFoJ+Q@mail.gmail.com>
	 <CALCETrWYrR2X9u7CAr5xkSg8kLH_O=sdk=JF+ZW+FxCTNTFBZg@mail.gmail.com>
	 <CA+mtBx9dSNOD5Z8GinU8F1mj_PgU0sTC5g8S9vRuSnSUzAoD=g@mail.gmail.com>
	 <CALCETrXf8j52nmpw-A2+bQt0yoz-fiD-4GP4Qf-afwH6UjCVnw@mail.gmail.com>
	 <1416003883.17262.72.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALCETrWhsj+byMeT=WHb9eLR_vgsUe58Li8JDLaTvsSPWp1DKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ying Cai <ycai-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neal Cardwell <ncardwell-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrWhsj+byMeT=WHb9eLR_vgsUe58Li8JDLaTvsSPWp1DKQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-11-14 at 14:27 -0800, Andy Lutomirski wrote:

> The people at the other end will be really pissed if that results in
> lots of reconnections.

No reconnections necessary.

I believe you misunderstood : On the 4-tuple (SADDR,SPORT,DADDR,DPORT),
you can pick for example SPORT so that hash(SADDR,SPORT,DADDR,DPORT)
maps to a known and wanted RX queue number.

Once you know that, you use bind(SADDR, SPORT), then
connect(DADDR,DPORT). 

Anyway, if your hardware is able to cope with the few number of flows,
just use the hardware and be happy.

Here we want about 10 millions sockets, there is little hope for
hardware being helpful.
