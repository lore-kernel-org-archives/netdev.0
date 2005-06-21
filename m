From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch] devinet: cleanup if statements
Date: Tue, 21 Jun 2005 13:48:22 -0700 (PDT)
Message-ID: <20050621.134822.21926602.davem@davemloft.net>
References: <200506072032.NAA06207@allur.sanmateo.akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pmeda@akamai.com
In-Reply-To: <200506072032.NAA06207@allur.sanmateo.akamai.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: pmeda@akamai.com
Date: Tue, 7 Jun 2005 13:32:44 -0700

> Cleanup the devinet if statements.
>  - when there is no colon, interface name is same as device.
>  - ifa_label is an array, not a pointer, and so can never be null.
> 
> Signed-Off-by: Prasanna Meda <pmeda@akamai.com>

Ok, I can see how your first change is correct.

When there is a colon, we've modified ifr.ifr_name by
patching the ':' character to be a '\0'.  This is for
the __dev_get_by_name() lookup.

After that lookup, we re-patch the ':' character back
into ifr.ifr_name.  So indeed, always using the ifr_name
in that code block would be correct.

The second hunk of your patch seems to defeat the intention
of that code.  I believe the idea is that if the label and
the device name differ, use the label.

This whole area is pretty messy, we should examine the true
intended semantics of the ifa_label stuff.
