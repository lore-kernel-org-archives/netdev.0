From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix tcp_default_win_scale.
Date: Tue, 6 Jul 2004 13:33:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706133343.111556a8.davem@redhat.com>
References: <32886.63.170.215.71.1088564087.squirrel@www.osdl.org>
	<20040629222751.392f0a82.davem@redhat.com>
	<20040630152750.2d01ca51@dell_ss3.pdx.osdl.net>
	<20040630153049.3ca25b76.davem@redhat.com>
	<20040701133738.301b9e46@dell_ss3.pdx.osdl.net>
	<20040701140406.62dfbc2a.davem@redhat.com>
	<20040702013225.GA24707@conectiva.com.br>
	<20040706093503.GA8147@outpost.ds9a.nl>
	<20040706114741.1bf98bbe@dell_ss3.pdx.osdl.net>
	<20040706185856.GN18841@lug-owl.de>
	<20040706131731.540dd5fd.davem@redhat.com>
	<20040706133146.7ed47c69@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jbglaw@lug-owl.de, linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040706133146.7ed47c69@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004 13:31:46 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The default tcp_rmem[2] is 174760, so we only need a wscale of 2 to represent
> that. We were sending 7.

It's only going to paper over this problem, because a window scale
of 2 still gets edited by the firewalls yet doesn't cause the
kind of damage 7 does.

Also, using a value of 7 is very safe, because it handles even the
tinyest of MTU's in use today (512 byte SLIP connections, for example
can still advertise sub-MTU sized chunks in the window).  Since
a window scale of 7 allows a granularity of 128 octets.
