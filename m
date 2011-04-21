From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [RFC v3 5/6] j1939: rename NAME to UUID?
Date: Thu, 21 Apr 2011 08:54:45 +0200
Message-ID: <20110421065445.GA332@kurt.e-circ.dyndns.org>
References: <20110314132004.GA333@e-circ.dyndns.org>
	<20110314135917.GF333@e-circ.dyndns.org>
	<4D8623BE.2080807@hartkopp.net>
	<20110413044928.GA289@kurt.e-circ.dyndns.org>
	<4DA88705.5040203@hartkopp.net>
	<20110420072439.GB332@kurt.e-circ.dyndns.org>
	<4DAEBC94.5020009@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4DAEBC94.5020009-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

> 
> Kurt, the problem for me is, that you constantly state that your approach is
> the best. For me it is not.
no userspace counterpart can handle transient conditions like kernel can...
> 
> The major issue in your implementation is the lack of the possibility to
> simulate several j1939 ECUs on one Linux host talking to each other via
> virtual CAN busses to create a complete j1939 network. And so far you did not
> address this request.
Oliver,
I tried to explain already several times that this stack _IS_ capable
of having several j1939 ECU's on one linux host, talking to any CAN bus, virtual
or physical.
I agree that if this was not the case, your arguments would have been valid.

The major improvement (IMHO) of my in-kernel j1939 stack is that several
applications can also contribute to the same ECU, without protocol violations.

side note: this is not even a matter introduced with address claiming :-0
> 

ever done this?
$ ip addr add 192.168.0.1/24 dev eth0
$ ip addr add 192.168.1.1/24 dev eth0

Likewise I do now:
$ ip addr add j1939 0x20 dev can0
$ ip addr add j1939 0x21 dev can0

I see no problem there.

With address claiming:
$ ip addr add j1939 name 0123456789ABCDE0 dev can0
$ ip addr add j1939 name 0123456789ABCDE1 dev can0
and my daemon to choose addresses (posted later today on can-utils)

$ jacd --range 0x20-0x30 0123456789ABCDE0 can0
$ jacd --range 0x20-0x30 0123456789ABCDE1 can0

No, no typos here. both ECU's will resolve conflicts on CAN, on the same host!
The second will ECU will finally get 0x21, _as should be_ per J1939.

Oliver,
The way I understand your request, this addressed that. What did I miss up to here?

I skipped a lot of your original email since the issue addressed here seems to
be source of misunderstanding.

Kind regards,
Kurt
