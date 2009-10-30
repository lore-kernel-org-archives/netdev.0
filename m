From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH 1/3] net: TCP thin-stream detection
Date: Fri, 30 Oct 2009 12:13:14 -0400
Message-ID: <4AEB109A.7090506@gmail.com>
References: <52481f5b4edfdbd96dcde46aed403fcf.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: apetlund@simula.no,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Christian Samsel <christian.samsel@rwth-aachen.de>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932568AbZJ3QNR@vger.kernel.org>
In-Reply-To: <52481f5b4edfdbd96dcde46aed403fcf.squirrel@webmail.uio.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

apetlund@simula.no wrote:
> I share the opinion that the linear timeouts should be limited, and back
> off exponentially after the limit, as Eric suggested. I believe this will
> be a sufficient safety-valve for the black-hole scenario, although I would
> like to run some tests.
> 
> As I wrote to Arnd, there are many similarities with the EFR approach and
> what our patch does. The largest difference is that the thin-stream
> patterns are identified as an indication of time dependent/interactive
> apps. This is the reason why the proposed patch does not try to keep an
> inflated cwnd open, but only focuses on the cases of few packets in
> flight. The target is time-dependent/interactive applications, and as such
> we don't want a generally enabled mechanism, but want to give the option
> of enabling it only in the cases where they are most needed (in contrast
> to a generally enabled "automagically" triggered EFR).
> 
> Below is a link to a table presenting some of the applications that we
> have traced and analysed the packet interarrival times of:
> 
> http://folk.uio.no/apetlund/lktmp/thin_apps_table.pdf
> 
> We were surprised to see how many cases of "thin-stream" traffic patterns
> were indicative of time-dependent/interactive apps.
> 
I'm finding it hard to follow 3 threads, for the 3 parts of the patch.

As I mentioned in one of these threads, I've plenty of experience with
designing and implementing protocols for gaming.  And it seems to me that
you're making changes to the entire TCP stack to make up for shortcomings
in the implementor's design.  Yet, these changes require application
implementors to set a sockopt that's only available in Linux.  Unlikely,
as they probably don't even keep track of such things....

There are other efforts in this area, they've been mentioned.

I'm new to this list, so I'm not entirely sure that protocol design is
regularly discussed here.  But I'd prefer that the discussion moved to
one of the lists that's dedicated to such protocol design and testing.

I've already suggested the end-to-end interest list, where you'll find many
of us with a strong interest in this topic.

List-Subscribe: <http://mailman.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=subscribe>

The IETF has two related working groups:
   tcpm -- tcp modifications
   tsvwg -- general transport, including sctp modifications

Without further ado, just count me as opposed at this time.
