From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: Cleaner way to conditionally disallow a CONFIG option as static
Date: Wed, 10 Mar 2004 10:16:27 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403101006390.3016@localhost.localdomain>
References: <Pine.LNX.4.58.0403081659170.1656@localhost.localdomain>
 <Pine.LNX.4.58.0403100437040.27654@serv>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kaos@ocs.com.au, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roman Zippel <zippel@linux-m68k.org>
In-Reply-To: <Pine.LNX.4.58.0403100437040.27654@serv>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Mar 2004, Roman Zippel wrote:

> Hi,
>
> On Mon, 8 Mar 2004, Sridhar Samudrala wrote:
>
> > In 2.6, net/sctp/Kconfig
> >
> > config IPV6_SCTP__
> > 	tristate
> > 	default y if IPV6=n
> > 	default IPV6 if IPV6
> >
> > config IP_SCTP
> > 	tristate "The SCTP Protocol (EXPERIMENTAL)"
> > 	depends on IPV6_SCTP__
>
> This can be written as:
>
> config IP_SCTP
> 	tristate "The SCTP Protocol (EXPERIMENTAL)"
> 	depends on IPV6 || IPV6=n
>

Thanks. Your 2.6 solution helped me come up with the following solution for
2.4 too and avoid the hack.

if [ "$CONFIG_IPV6" = "n" ]; then
  tristate '  The SCTP Protocol (EXPERIMENTAL)' CONFIG_IP_SCTP
else
  dep_tristate '  The SCTP Protocol (EXPERIMENTAL)' CONFIG_IP_SCTP $CONFIG_IPV6
fi

Thanks
-Sridhar
