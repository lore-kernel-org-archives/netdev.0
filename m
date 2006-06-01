From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [openib-general] Re: [PATCH 1/2] iWARP Connection Manager.
Date: Thu, 1 Jun 2006 15:28:24 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F150D3E6@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Steve Wise" <swise@opengridcomputing.com>, netdev@vger.kernel.org,
	rdreier@cisco.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750814AbWFAW2p@vger.kernel.org>
Content-class: urn:content-classes:message
To: "Tom Tucker" <tom@opengridcomputing.com>,
	"Sean Hefty" <mshefty@ichips.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> 
>> There's a difference between trying to handle the user calling
>> disconnect/destroy at the same time a call to accept/connect is
>> active, versus the user calling disconnect/destroy after
>> accept/connect have returned.  In the latter case, I think you're
>> fine.  In the first case, this is allowing a user to call
> destroy at the same time that they're calling accept/connect.
>> Additionally, there's no guarantee that the F_CONNECT_WAIT flag has
>> been set by accept/connect by the time disconnect/destroy tests it.
> 
> The problem is that we can't synchronously cancel an
> outstanding connect request. Once we've asked the adapter to
> connect, we can't tell him to stop, we have to wait for it to
> fail. During the time period between when we ask to connect
> and the adapter says yeah-or-nay, the user hits ctrl-C. This
> is the case where disconnect and/or destroy gets called and
> we have to block it waiting for the outstanding connect
> request to complete.
> 
> One alternative to this approach is to do the kfree of the
> cm_id in the deref logic. This was the original design and
> leaves the object around to handle the completion of the
> connect and still allows the app to clean up and go away
> without all this waitin' around. When the adapter finally
> finishes and releases it's reference, the object is kfree'd.
> 
> Hope this helps.
> 
Why couldn't you synchronously put the cm_id in a state of
"pending delete" and do the actual delete when the RNIC
provides a response to the request? There could even be
an optional method to see if the device is capable of
cancelling the request. I know it can't yank a SYN back
from the wire, but it could refrain from retransmitting.
