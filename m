From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: Flush Tx skbs after link down
Date: Wed, 15 Jan 2003 00:31:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E01087ADF@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Cc: "Cramer, Jeb J" <jeb.j.cramer@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
content-class: urn:content-classes:message
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Someone most know the answer to this: What's the proper way to dispose
of Tx skbs that are owned by the h/w ("in-flight") when link was lost?
Lets say your h/w stops Tx processing when link is lost, but you've got
apps waiting for those Tx resources to be returned.  h/w isn't giving
those resources back until link is up.  Bonding doesn't like this.

We've tried walking the h/w list, and skb_orphan'ing the skbs, but that
only works if the usage count = 1.  The other solution is to tear down
and rebuild the Tx ring, but that requires a h/w reset to recover.  Yuk!

Any ideas?

-scott
