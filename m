From: "Ronnie Sahlberg" <ronnie_sahlberg@ozemail.com.au>
Subject: Re: TCP hangs --- zero window probes
Date: Wed, 5 May 2004 17:49:04 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <054401c43275$70738d80$6501010a@C5043436>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Are you sure they are zero window probes and not normal keep-alives?

A zero window probe contains one byte of payload just beyong the right edge
of the window, thats why they are
called zero window probes : send one extra byte of data even though the
window is zero to opportunistically probe
if the window has opened again.

zero window probes also usually run on a normal constant timer and usually
do not contain any exponential backoff.


a tcp keepalive on the other hand usually
transmit an "invalid" segment containing zer or 1 byte of payload just one
byte prior to the left edge of the window.
These usually have an exponential backoff in the same way as normal data
segments have.
These segments have deliberately an sequence number outside of the expected
window so that they will
trigger an immediate ACK to be sent back from the other side.


An implementation that can not send an immediate ACK back to a keep-alive is
completely broken.
