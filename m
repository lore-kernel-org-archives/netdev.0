From: Andy King <acking@vmware.com>
Subject: Re: [RFC 4/5] VSOCK: Introduce vhost-vsock.ko
Date: Thu, 27 Jun 2013 19:38:43 -0700 (PDT)
Message-ID: <1767234411.9934439.1372387123615.JavaMail.root@vmware.com>
References: <1372320004-20502-1-git-send-email-asias@redhat.com> <1372320004-20502-5-git-send-email-asias@redhat.com> <20130627104246.GC20215@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Asias He <asias@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>,
	Dmitry Torokhov <dtor@vmware.com>,
	Reilly Grant <grantr@vmware.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jason Wang <jasowang@redhat.com>,
	Stefan Hajnoczi <stefanha@gmail.com>,
	Gerd Hoffmann <kraxel@redhat.com>,
	Pekka Enberg <penberg@kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:56591 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754315Ab3F1Cip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 22:38:45 -0400
In-Reply-To: <20130627104246.GC20215@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

> > +	u32 cid = VHOST_VSOCK_DEFAULT_HOST_CID;
> > +	return cid;
> > +}
> > +
> 
> Interesting. So all hosts in fact have the same CID?

"Host" here means the thing _below_ the VM.  Any process running on
the host OS can be addressed with cid 2.  Each VM gets its own cid.
So communication is always between VM x <-> host 2.  That makes for
easy lookup on the VM's part.  (Note that we further distinguish in
the VMCI transport between the hypervisor, specifically the VM's own
VMX, which is on cid 0, and the host on cid 2.)

Thanks!
- Andy
