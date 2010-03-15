From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v1 2/3] Provides multiple submits and asynchronous
	notifications.
Date: Mon, 15 Mar 2010 11:23:01 +0200
Message-ID: <20100315092301.GC14999@redhat.com>
References: <1267868318-19268-1-git-send-email-xiaohui.xin@intel.com> <1267868318-19268-2-git-send-email-xiaohui.xin@intel.com> <1267868318-19268-3-git-send-email-xiaohui.xin@intel.com> <20100307111816.GC20004@redhat.com> <97F6D3BD476C464182C1B7BABF0B0AF5C164CEED@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"jdike@c2.user-mode-linux.org" <jdike@c2.user-mode-linux.org>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6290 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935892Ab0COJ0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Mar 2010 05:26:55 -0400
Content-Disposition: inline
In-Reply-To: <97F6D3BD476C464182C1B7BABF0B0AF5C164CEED@shzsmsx502.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 15, 2010 at 04:46:50PM +0800, Xin, Xiaohui wrote:
> >> +/* The structure to notify the virtqueue for async socket */
> >> +struct vhost_notifier {
> >> +	struct list_head list;
> > >+	struct vhost_virtqueue *vq;
> > >+	int head;
> > >+	int size;
> > >+	int log;
> > >+	void *ctrl;
> > >+	void (*dtor)(struct vhost_notifier *);
> > >+};
> > >+
> 
> >So IMO, this is not the best interface between vhost
> >and your driver, exposing them to each other unnecessarily.
> >
> >If you think about it, your driver should not care about this structure.
> >It could get e.g. a kiocb (sendmsg already gets one), and call ki_dtor
> >on completion.  vhost could save it's state in ki_user_data.  If your
> >driver needs to add more data to do more tracking, I think it can put
> >skb pointer in the private pointer.
> 
> Then if I remove the struct vhost_notifier, and just use struct kiocb, but don't use the one got from sendmsg or recvmsg, but allocated within the page_info structure, and don't implement any aio logic related to it, is that ok?

Hmm, not sure I understand.  It seems both cleaner and easier to use the
iocb passed to sendmsg/recvmsg. No? I am not saying you necessarily must
implement full aio directly.

> Sorry, I made a patch, but don't know how to reply mail with a good formatted patch here....
> 
> Thanks
> Xiaohui

Maybe Documentation/email-clients.txt will help?
Generally you do it like this (at start of mail):

Subject: one line patch summary (overrides mail subject)

multilie patch description

Signed-off-by: <...>

---

Free text comes after --- delimeter, before patch.

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index a140dad..e830b30 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -106,22 +106,41 @@ static void handle_tx(struct vhost_net *net)




-- 
MST
