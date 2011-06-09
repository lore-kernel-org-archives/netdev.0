From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2i: fix bnx2i driver to test for physical device
 support of iscsi early
Date: Wed, 8 Jun 2011 17:46:23 -0700
Message-ID: <C27F8246C663564A84BB7AB343977242667C64F9B5@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <1307561363-11677-1-git-send-email-nhorman@tuxdriver.com>
 <1307563443.8532.42.camel@HP1>
 <20110609001948.GA8203@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'Mike Christie'" <michaelc@cs.wisc.edu>,
	"'David S. Miller'" <davem@davemloft.net>
To: "'Neil Horman'" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4027 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751382Ab1FIAq0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 20:46:26 -0400
In-Reply-To: <20110609001948.GA8203@neilslaptop.think-freely.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:

> How do you figure?  bnx2_cnic_probe is only called from is_cnic_dev
> (which still
> makes me shake my head a bit).  is_cnic_dev is only called from
> cnic_netdev_event, which holds the rtnl_lock.  Since the event we
> trigger on is
> called from NETDEV_REGISTER or NETDEV_UP, I don't see how we can wind
> up
> suspending the device prior to caling bnx2_cnic_probe.

Consider NETDEV_REGISTER -> NETDEV_UP -> NETDEV_DOWN

During NETDEV_DOWN, we shutdown the device, but the netdev is still
registered.

Then we load cnic.  The NETDEV events will be replayed when we call
netdev_register_notifier() and cnic will get the NETDEV_REGISTER event.
We'll then call bnx2_cnic_probe() but the device is down.


