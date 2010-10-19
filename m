From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Tue, 19 Oct 2010 09:28:44 -0400
Message-ID: <20101019132844.GB14410@hmsreliant.think-freely.org>
References: <4CBCD429.8090306@windriver.com>
	<20101018234547.GA5703@hmsreliant.think-freely.org>
	<20101019021657.GZ8781@llucax.com.ar>
	<20101019.011649.71113115.davem@davemloft.net>
	<20101019110452.GA14410@hmsreliant.think-freely.org>
	<20101019131936.GB8781@llucax.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paul.gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, David Miller <davem@davemloft.net>
To: Leandro Lucarella <luca@llucax.com.ar>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20101019131936.GB8781@llucax.com.ar>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Oct 19, 2010 at 10:19:36AM -0300, Leandro Lucarella wrote:
> Neil Horman, el 19 de octubre a las 07:04 me escribiste:
> > On Tue, Oct 19, 2010 at 01:16:49AM -0700, David Miller wrote:
> > > From: Leandro Lucarella <luca@llucax.com.ar>
> > > Date: Mon, 18 Oct 2010 23:16:57 -0300
> > > =

> > > > =

> > > > The problem is not between the tipc stacks in different hosts, is
> > > > between the tipc stack and the applications using it (well, maybe
> > > > there is a problem somewhere else too).
> > > > =

> > > > This was a deliberate API change, not a subtle bug...
> > > =

> > > Neil et al., if these packets live only between the kernel stack
> > > and the userspace API layer, we should not be byte-swapping this
> > > stuff and we need to fix this fast.
> > > =

> > Copy that Dave.  I think I see the problem.  The subscription code hand=
les
> > messages both off the wire and from local user space.  The off the wire=
 case
> > should work because the subscription code assumes that all the incommin=
g data is
> > in network byte order, but user space is an exception to that rule as i=
ts in
> > local byte order.  I'll have a patch together for Leandro to test soon.
> > Neil
> =

> Thank you very much. Bare in mind that the byte order is just one of the
> problems, the other problem is the change in the value of
> TIPC_SUB_SERVICE from 2 to 0. That too is breaking the API/ABI, as
> a message with a filter value of 2 is rejected by TIPC 2.0/2.6.35+.
> =

Yeah, that was the format change.  We might just need to revert that.  Lets=
 see
about getting the endianess issue straight, and we'll go from there.
Neil

> -- =

> Leandro Lucarella (AKA luca)                     http://llucax.com.ar/
> ----------------------------------------------------------------------
> GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05)
> ----------------------------------------------------------------------
> Dentro de 30 a=F1os Argentina va a ser un gran supermercado con 15
> changuitos, porque esa va a ser la cantidad de gente que va a poder
> comprar algo.
> 	-- Sidharta Wiki
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> =


---------------------------------------------------------------------------=
---
Download new Adobe(R) Flash(R) Builder(TM) 4
The new Adobe(R) Flex(R) 4 and Flash(R) Builder(TM) 4 (formerly =

Flex(R) Builder(TM)) enable the development of rich applications that run
across multiple browsers and platforms. Download your free trials today!
http://p.sf.net/sfu/adobe-dev2dev
