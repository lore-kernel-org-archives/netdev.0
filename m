From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: IPV6 RFC3542 compliance [PATCH]
Date: Mon, 6 Jun 2005 23:35:46 -0700
Message-ID: <OF33EBAE56.7D53F432-ON88257019.0023E21E-88257019.00243C3C@us.ibm.com>
References: <OF9F62ECDB.67FFA191-ON88257019.001F5EA8-88257019.00234AB6@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <OF9F62ECDB.67FFA191-ON88257019.001F5EA8-88257019.00234AB6@us.ibm.com>
To: David Stevens <dlstevens@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

PS -

I should've said clearly; with the patch I submitted as-is, all
old binaries should return EINVAL on the socket options
that have changed. That's because all of those (except the
new IPV6_TCLASS, which didn't exist before) have option
arguments greater than int-size.

Recompiling those programs will still result in the setsockopt()
returning EINVAL, until the source is fixed to change the
socket options to the IPV6_RECVx.

sendmsg() and recvmsg() processing in old binaries should
still work, as-is.

So, with that patch, programs using the old names will give
a strong indication of what needs fixing.

                                        +-DLS
