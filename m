From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: Open vSwitch Design
Date: Fri, 25 Nov 2011 12:20:06 -0800
Message-ID: <CAEP_g=9tcH9kJrVsHc26kXWZEUS8G-U=U7y6k8xaZG5MD0OTyg@mail.gmail.com>
References: <1322173833.1944.5.camel@mojatatu>
	<20111124212021.2ae2fb7f@s6510.linuxnetplumber.net>
	<1322201883.2872.19.camel@edumazet-laptop>
	<20111125.012517.2221372383643417980.davem@davemloft.net>
	<1322203013.2872.28.camel@edumazet-laptop>
	<1322220862.1908.79.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org, shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1322220862.1908.79.camel@mojatatu>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 25, 2011 at 3:34 AM, jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org> wrote:
>
> Hrm. I forgot about the flow classifier - it may be what the openflow
> folks need. It is more friendly for the well defined tuples than u32.

The flow classifier isn't really designed to do rule lookup in the way
that OpenFlow/Open vSwitch does, since it's more about choosing which
fields are considered significant to the flow.  I'm sure that it could
be extended in some way but it seems that the better approach would be
to factor out the common pieces (such as the header extraction
mentioned before) than try to cram both models into one component.

I understand that you see some commonalities with various parts of the
system but often there are enough conceptual differences that you end
up trying to shove a square peg into a round hole.  As Stephen
mentioned about the bridge, many of these components are already
fairly complex and combining more functionality into them isn't always
a win.
