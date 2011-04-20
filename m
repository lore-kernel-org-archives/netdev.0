From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [RFC v3 5/6] j1939: rename NAME to UUID?
Date: Wed, 20 Apr 2011 09:24:39 +0200
Message-ID: <20110420072439.GB332@kurt.e-circ.dyndns.org>
References: <20110314132004.GA333@e-circ.dyndns.org>
	<20110314135917.GF333@e-circ.dyndns.org>
	<4D8623BE.2080807@hartkopp.net>
	<20110413044928.GA289@kurt.e-circ.dyndns.org>
	<4DA88705.5040203@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4DA88705.5040203-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
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

On Fri, Apr 15, 2011 at 07:57:25PM +0200, Oliver Hartkopp wrote:
> On 13.04.2011 06:49, Kurt Van Dijck wrote:
> > Oliver et.al.,
> 
> Thinking about the approach to implement the j1939 address claiming (AC) in
> userspace, i discovered two ways which could both be hidden inside some
> easy-to-use helper functions:
> 
> 1. implement a thread (e.g. within a library) which opens a CAN_RAW socket on
> a specific CAN-interface and takes care of the AC procedure and monitors
> ongoing AC procedures on the bus. In this case every j1939 application
> requiring AC internally would monitor all the AC handling on itself (which
> should be no general problem - written only once).
> 
> 2. create j1939ac daemon(s) using PF_UNIX-sockets to be named e.g.
> j1939ac_can0, j1939ac_can1, etc. - these daemons take care for all AC
> requirements of the host it is running on. The PF_UNIX-sockets are used in
> SOCK_DGRAM mode and only the j1939 processes that need AC can then register
> their NAME by sending a request datagram, and get back the j1939-address once
> it is claimed (and all the updates on changes). As the j1939ac daemons are
> running on the same host as the j1939 application processes, optional the
> process' PID could be provided to the daemon during the registering process,
> so that the daemon can send a signal to a signal handler of the application
> process (if you would like to omit the select() syscall to handle both the
> j1939 and PF_UNIX sockets).
> 
> ->   <Req><Name="A3B5667799332242" PID="12345">
> <-   <Resp><ACState="claimed" Name="A3B5667799332242" Address="1B">
> (some time)
> <-   <Resp><ACState="changed" Name="A3B5667799332242" Address="1C">
> 
> This is a sketch that could be put into simple C-structs that are sent via the
> PF_UNIX DGRAM socket.
> 
> In all suggested cases (using a thread, daemon with/without signal) the AC
> procedure can be managed in userspace without real pain.
I seriously doubt this statement.
define 'real pain'.
> But especially with
> less pain than putting the AC process into kernelspace and provide your
> suggested socket API with bind/connect/... in very different manners.
* You're only counting LOC in kernel, and not in userspace.
* The constructs you present create some kind of infrastructure. You will
  need a torough documentation of the 'good practice' since that's crucial
  to the correct operation of the stack. Did you ever consider the impact
  on the userspace application side.
  Remember that userspace programs should be easy to write.
  I found your proposals impact application development very hard.


I still think my passive support in kernel performs better and gives an
easier API to get things done with.

I have it all operating, both embedded and on dual-core 64bit system.
I need to git pull the latest updates, and I'll send a revised patchset
tomorrow.

Kind regards,
Kurt
