From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Cleaner way to conditionally disallow a CONFIG option as static
Date: Mon, 8 Mar 2004 17:22:35 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403081659170.1656@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kaos@ocs.com.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

SCTP is allowed to be static only when IPV6 is also configured as static or
not enabled. If IPV6 is configured as a module, SCTP also has to be a module.
This is done right now in the following hackish ways in 2.6 and 2.4 using an
additional config option(CONFIG_IPV6_SCTP__).

In 2.6, net/sctp/Kconfig

config IPV6_SCTP__
	tristate
	default y if IPV6=n
	default IPV6 if IPV6

config IP_SCTP
	tristate "The SCTP Protocol (EXPERIMENTAL)"
	depends on IPV6_SCTP__
--------------------------------------------------------
In 2.4, net/sctp/Config.in

if [ "$CONFIG_IPV6" != "n" ]; then
   define_bool CONFIG_IPV6_SCTP__ $CONFIG_IPV6
else
   define_bool CONFIG_IPV6_SCTP__ y
fi

dep_tristate '  The SCTP Protocol (EXPERIMENTAL)' CONFIG_IP_SCTP $CONFIG_IPV6_SCTP__
--------------------------------------------------------

Is there a much simpler and cleaner way to accomplish this in 2.6 and 2.4
config files?

Thanks
Sridhar
