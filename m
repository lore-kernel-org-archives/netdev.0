From: "David S. Miller" <davem@redhat.com>
Subject: Re: analysis of TCP window size issues still around - several
 reports / SACK involved?
Date: Tue, 6 Jul 2004 13:19:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706131955.3a3c6c8b.davem@redhat.com>
References: <32886.63.170.215.71.1088564087.squirrel@www.osdl.org>
	<20040629222751.392f0a82.davem@redhat.com>
	<20040630152750.2d01ca51@dell_ss3.pdx.osdl.net>
	<20040630153049.3ca25b76.davem@redhat.com>
	<20040701133738.301b9e46@dell_ss3.pdx.osdl.net>
	<20040701140406.62dfbc2a.davem@redhat.com>
	<20040702013225.GA24707@conectiva.com.br>
	<20040706093503.GA8147@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, shemminger@osdl.org, netdev@oss.sgi.com,
        alessandro.suardi@oracle.com, phyprabab@yahoo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20040706093503.GA8147@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004 11:35:03 +0200
bert hubert <ahu@ds9a.nl> wrote:

> 22:42:40.890025 192.168.1.6.32843 > 204.152.189.116.http: S 1994994484:1994994484(0) win 5840 <mss 1460,sackOK,timestamp 4294940315 0,nop,wscale 7> (DF)
> 22:42:41.143063 204.152.189.116.http > 192.168.1.6.32843: S 1404108869:1404108869(0) ack 1994994485 win 5792 <mss 1452,sackOK,timestamp 3383469176 4294940315,nop,wscale 0> (DF)
> 22:42:41.143123 192.168.1.6.32843 > 204.152.189.116.http: . ack 1 win 45 <nop,nop,timestamp 4294940568 3383469176> (DF)
> 
> Alessandro's machine does perform window scaling, tcpdump however does not
> understand that and neglects to multiply 45 by 2^7 (=5760). Kernel.org does do
> wscale, but defaults to 2^0.

tcpdump's behavior is correct, it's just reporting the raw window
field in the TCP header, unscaled, and that is fine.  In fact I'd
rather it do this, so that diagnosing dumps are easier.  If tcpdump
tries to be too clever, scaling the window, then I might end up
chasing down a tcpdump bug rather than a TCP one :-)

What would be more interesting is to get the tcpdump trace from the
other side of this connection.  This is crucial, as it will show how
and in what way exactly the window scale options and/or window fields
are being edited by a firewall or other device and thus causing
the problems.
