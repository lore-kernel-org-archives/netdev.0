From: Werner Almesberger <wa@almesberger.net>
Subject: TCP connection passing, version 3
Date: Fri, 1 Nov 2002 18:21:23 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021101182123.A30594@almesberger.net>
References: <20021031000249.A20233@almesberger.net> <20021031045909.A15756@almesberger.net> <20021031200017.A21544@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20021031200017.A21544@almesberger.net>; from wa@almesberger.net on Thu, Oct 31, 2002 at 08:00:17PM -0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Almost a whole day since the last update ! High time for something
new:

http://www.almesberger.net/tcpcp/tcpcp-3.tar.gz

The main change this time is that restarting the connection is no 
longer done by setting TCP_ICI, but by setting the new socket 
option TCP_KICK. This avoids the "need to reconfigure firewall 
within RTT or performance may suffer" race for applications.

So this leaves mainly the difficult parts (OOO recovery and
urgent data) to implement/fix.

- Werner

----------------------------------- CHANGES -----------------------------------

Version 3 (1-NOV-2002)
----------------------

- moved activation of dormant connection from TCP_ICI/tcpcp_create to new
  socket option TCP_KICK and API function tcpcp_kick
- tcpcp_getici now returns any errors pending in sk->err
- API: added tcpcp_set_dst to set the destination address/port
- added "install" and "uninstall" make targets
- libtcpcp is now a shared library
- dumpici: added option -V that prints version information
- API: tcpcp_set_cong now sets errno
- README.HANDOVER: documented single host case and added TCP_KICK
- described not preserving error queue as feature, not bug
- minor cleanup here and there

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
