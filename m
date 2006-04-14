From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 05/10] e1000: Update truesize with the length of the
 packet for packet split
Date: Fri, 14 Apr 2006 15:43:02 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0604141533250.2116@jbrandeb-desk.amr.corp.intel.com>
References: <20060414183658.3461.4975.stgit@gitlost.site> <4440112D.9040509@pobox.com>
 <Pine.WNT.4.63.0604141448520.2116@jbrandeb-desk.amr.corp.intel.com>
 <20060414.153219.62111494.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jesse.brandeburg@intel.com, jgarzik@pobox.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	john.ronciak@intel.com, Jeffrey.t.kirsher@intel.com,
	auke@foo-projects.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:53396 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751297AbWDNWnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 18:43:47 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060414.153219.62111494.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 14 Apr 2006, David S. Miller wrote:

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Date: Fri, 14 Apr 2006 15:13:31 -0700 (Pacific Daylight Time)
> 
> > in the old driver we indicate a packet with truesize = 128, which has 1000 
> > bytes of data in it.  normally (for everyone using only an skb) skb->len, 
> > and skb->truesize are updated by skb_put();  In this case we don't have a 
> > kernel support function for adding length to skb->len *and* to 
> > skb->truesize when chaining on something to ->frags[]
> 
> Where does skb_put() update truesize?

my mistake, it does not.  but truesize in the "normal" case is already set 
to the full length of the allocated skb (which would hold the whole 
frame).  In the packet split case the received skb looks dramatically 
different, and since we're one of the only drivers using this mechanism.

I could easily be incorrect here, but my interpretation based on the 
stack's use of ->truesize in do_tcp_sendpages is what I based our code 
change on.

Please help me understand how you think it should work when we have a 
device that wants to receive a packet using header in the skb->data, and 
application data in the ->frags[]? 

Jesse
