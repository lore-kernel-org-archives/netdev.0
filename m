From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2.6.8] ipvs - do not use skb_checksum_help
Date: Tue, 17 Aug 2004 20:51:39 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0408172045280.2277-100000@l>
References: <Xine.LNX.4.44.0408171334200.10178-100000@dhcp83-76.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Wensong Zhang <wensong@linux-vs.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0408171334200.10178-100000@dhcp83-76.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 17 Aug 2004, James Morris wrote:

> On Tue, 17 Aug 2004, Wensong Zhang wrote:
>
> > Agree with Julian that there is no need to call skb_checksum_help in IPVS.
>
> What if you have a cloned skb?  It needs to be copied.

	No problem, there is already ip_vs_make_skb_writable() which 
properly handles such skb states. It is used in lots of places in ipvs/:

root@b:/usr/src/linux-2.6.8.1# grep -r ip_vs_make_skb_writable net/ipv4/ipvs/|wc -l
14

	For read access skb_copy_bits() is used:

root@b:/usr/src/linux-2.6.8.1# grep -r skb_copy_bits net/ipv4/ipvs/|wc -l
23

> - James

Regards

--
Julian Anastasov <ja@ssi.bg>
