From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bnx2i: fix bnx2i driver to test for physical device
 support of iscsi early
Date: Wed, 8 Jun 2011 21:14:58 -0400
Message-ID: <20110609011457.GA9603@neilslaptop.think-freely.org>
References: <1307561363-11677-1-git-send-email-nhorman@tuxdriver.com>
 <1307563443.8532.42.camel@HP1>
 <20110609001948.GA8203@neilslaptop.think-freely.org>
 <C27F8246C663564A84BB7AB343977242667C64F9B5@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	'Mike Christie' <michaelc@cs.wisc.edu>,
	"'David S. Miller'" <davem@davemloft.net>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46601 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382Ab1FIBPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 21:15:11 -0400
Content-Disposition: inline
In-Reply-To: <C27F8246C663564A84BB7AB343977242667C64F9B5@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 08, 2011 at 05:46:23PM -0700, Michael Chan wrote:
> Neil Horman wrote:
> 
> > How do you figure?  bnx2_cnic_probe is only called from is_cnic_dev
> > (which still
> > makes me shake my head a bit).  is_cnic_dev is only called from
> > cnic_netdev_event, which holds the rtnl_lock.  Since the event we
> > trigger on is
> > called from NETDEV_REGISTER or NETDEV_UP, I don't see how we can wind
> > up
> > suspending the device prior to caling bnx2_cnic_probe.
> 
> Consider NETDEV_REGISTER -> NETDEV_UP -> NETDEV_DOWN
> 
> During NETDEV_DOWN, we shutdown the device, but the netdev is still
> registered.
> 
> Then we load cnic.  The NETDEV events will be replayed when we call
> netdev_register_notifier() and cnic will get the NETDEV_REGISTER event.
> We'll then call bnx2_cnic_probe() but the device is down.
Ah,ok.  Please CC me on your patch.
Neil
