From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [2/4] pollcontroller patch for 2.6.0-test10-bk25-netdrvr-exp1
Date: Fri, 5 Dec 2003 13:36:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDD27@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <mpm@selenic.com>, <suparna@in.ibm.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>, <prasanna@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> For both, as Scott mentioned, they don't look tested under NAPI.  For 
> e100 specifically, there is a spiffy new e100 that would need to be 
> re-diffed and tested against.

Specifically, we need to care about insuring netif_rx is called in the
poll_controller callback, rather than netif_receive_skb.  If you use
netif_receive_skb (NAPI mode), the netdump conversation is one-sided.
tg3.c looks broken in this regard in the 2.6-exp BK tree, BTW.

Additionally, if you have VLANs enabled on the interface, we might need
to care about netif_hwaccell_[rx|receive_skb].  Something tells me all
of the netif_* receive funcs need to handle the netdump conversation.
That would be easier than special casing poll_controller in each driver.
Is someone working on this?

We're working on e100/e1000 patches for the current scheme, so we'll
post these when we've tested the various NAPI/VLAN combinations.

-scott
