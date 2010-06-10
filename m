From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: no reassembly for outgoing packets on RAW socket
Date: Thu, 10 Jun 2010 08:56:31 +0200
Message-ID: <20100610065631.GA1915@jolsa.lab.eng.brq.redhat.com>
References: <20100604112708.GA1958@jolsa.lab.eng.brq.redhat.com>
 <4C08EB85.3050900@trash.net>
 <20100607145558.GA1939@jolsa.lab.eng.brq.redhat.com>
 <4C0FA24A.7060907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C0FA24A.7060907@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 09, 2010 at 04:16:42PM +0200, Patrick McHardy wrote:
> Jiri Olsa wrote:
> > On Fri, Jun 04, 2010 at 02:03:17PM +0200, Patrick McHardy wrote:
> >   
> >> Jiri Olsa wrote:
> >>     
> >>> hi,
> >>>
> >>> I'd like to be able to sendout a single IP packet with MF flag set.
> >>>
> >>> When using RAW sockets the packet will get stuck in the
> >>> netfilter (NF_INET_LOCAL_OUT nf_defrag_ipv4 reassembly unit)
> >>> and wont ever make it out..
> >>>
> >>> I made a change which bypass the outgoing reassembly for
> >>> RAW sockets, but I'm not sure wether it's too invasive..
> >>>       
> >> That would break reassembly (and thus connection tracking) for cases
> >> where its really intended.
> >>
> >>     
> >>> Is there any standard for RAW sockets behaviour?
> >>> Or another way around? :)
> >>>       
> >> You could use the NOTRACK target to bypass connection tracking.
> >>     
> >
> > ok,
> >
> > I tried the NOTRACK target, but the packet is still going
> > throught reassembly, because the RAW filter has lower priority
> > then the connection track defragmentation..
> >   
> 
> Right.
> > I was able to get it bypassed by attached patch and following
> > command:
> >
> > 	iptables -v -t raw -A OUTPUT -p icmp -j NOTRACK
> >
> > again, not sure if this is too invasive ;)
> >   
> 
> Well, we can't change it in the mainline kernel.
> > If this is not the way, I'd appreciatte any hint..  my goal is
> > to put malformed packet on the wire (more frags bit set for a
> > non fragmented packet)
> 
> I don't have any good suggestions besides adding a flag to the IPCB
> and skipping defragmentation based on that.
ok,

I can see a way when I set this via setsockopt to the socket,
and check the value before the defragmentation..  would such a new
setsock option be acceptable?

I'm not sure I can see a way via IPCB, AFAICS it's for skb bound flags
which arise during the skb processing.

thanks,
jirka
