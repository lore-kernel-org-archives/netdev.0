From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 01/19] bna: use ether_addr_copy instead of
 memcpy
Date: Wed, 10 Jun 2015 10:57:13 -0700
Message-ID: <1433959033.32331.16.camel@perches.com>
References: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
	 <1433954605-22813-2-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rasesh.mody@qlogic.com
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0027.hostedemail.com ([216.40.44.27]:35477 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754314AbbFJR5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 13:57:16 -0400
In-Reply-To: <1433954605-22813-2-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-10 at 18:43 +0200, Ivan Vecera wrote:
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Have you verified that all of these are __aligned(2)?

I haven't, but you should verify that you have in the
commit log.

btw: this use looks odd to me:

static int
bnad_set_mac_address(struct net_device *netdev, void *mac_addr)
{
	int err;
	struct bnad *bnad = netdev_priv(netdev);
	struct sockaddr *sa = (struct sockaddr *)mac_addr;
	unsigned long flags;

	spin_lock_irqsave(&bnad->bna_lock, flags);

	err = bnad_mac_addr_set_locked(bnad, sa->sa_data);

as it casts what seems to be a mac address to a
sockaddr and uses a different offset for sa->sa_data
than the mac_addr passed.

and the mac_addr as it's void doesn't need a cast.
