From: "Meda, Prasanna" <pmeda@akamai.com>
Subject: RE: rcv_wnd = init_cwnd*mss
Date: Wed, 27 Oct 2004 23:15:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <DB2C167D8FFDEA45B8FC0B1B75E3EE154A3B08@usca1ex-priv1.sanmateo.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>, <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> From: David S. Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, October 27, 2004 10:21 PM
> To: Meda, Prasanna
> Cc: linux-kernel@vger.kernel.org; netdev@oss.sgi.com; davem@redhat.com
> Subject: Re: rcv_wnd = init_cwnd*mss
>
>
> On Wed, 27 Oct 2004 22:14:33 -0700
> "Meda, Prasanna" <pmeda@akamai.com> wrote:
>
> > 
> > What is the reason for checking mss with 1<<rcv_wscale?
> > include/net/tcp.h:

> Because the advertised window field is 16-bits.  It is
> interpreted as "value << rcv_wscale"

Thanks, still it is unclear to me why are we
downsizing the advertised window(rcv_wnd) to cwnd? 
To defeat disobeying sender, or something like below?

Suppose when wscale is zero, it is now checking mss > 1,
and perhaps the intention was to check mss > rcv_wnd,
where mss is greater than advertised, and we still
want to advertise window to spwan 2 to 4 cwnd packets.

And also in the following line,
if (*rcv_wscale && sysctl_tcp_app_win && space>=mss &&
                    space - max((space>>sysctl_tcp_app_win), mss>>*rcv_wscale) <
65536/2)

space is actual_space>>rcv_wscale, mss is actual value.
Why are we checking space>=mss, which are in different
scales? The second line is doing max on space and mss 
on same scales, and looks right.


Thanks,
Prasanna.
