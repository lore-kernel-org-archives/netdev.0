From: "David S. Miller" <davem@redhat.com>
Subject: Re: changing MTU on b44 breaks eth0
Date: Tue, 4 Nov 2003 09:13:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031104091355.70d6a3d1.davem@redhat.com>
References: <1067888106.3366.20.camel@bluez.bueche.ch>
	<20031103205335.GA7668@ee.oulu.fi>
	<20031103151618.79704b30.davem@redhat.com>
	<20031104111555.GA26860@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: charles@bueche.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20031104111555.GA26860@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 4 Nov 2003 13:15:55 +0200
Pekka Pietikainen <pp@ee.oulu.fi> wrote:

> Oh btw., when trying out whether the new code even compiles/loads
> I got the following in rmmod, does it look like something caused
> by generic code or should I look for a reason in b44? :-)
> (This is 2.6.0-test9-bk6).

free_netdev() is being invoked before the device registration
state advanced to NETREG_UNREGISTERED, likely unregister_netdev()
has not been called first or a bogus pointer was passed into
the routine.
