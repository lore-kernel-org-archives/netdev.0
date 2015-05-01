From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH 2/3] r8169: Use dev_kfree_skb in Tx cleanup path
Date: Fri, 01 May 2015 14:06:35 +0200
Message-ID: <55436C4B.7090509@gmx.de>
References: <20150430205423.1512.13487.stgit@ahduyck-vm-fedora22> <20150430205824.1512.35158.stgit@ahduyck-vm-fedora22> <20150501093420.GA11669@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Dept-HSGLinuxNICDev@qlogic.com, sony.chacko@qlogic.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	davem@davemloft.net, ebiederm@xmission.com
To: Francois Romieu <romieu@fr.zoreil.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:57309 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753463AbbEAMHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2015 08:07:24 -0400
In-Reply-To: <20150501093420.GA11669@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.05.2015 11:34, Francois Romieu wrote:
> Alexander Duyck <alexander.h.duyck@redhat.com> :
>> This change replaces the use of either dev_kfree_skb_any or
>> dev_consume_skb_any in the Tx cleanup path of this driver with
>> dev_kfree_skb.  There isn't any need for the "_any" version of these
>> functions since the NAPI cleanup context is not a hard irq context.
> 
> netconsole ?
> 
> __dev_kfree_skb_any contains a big "if (... || irqs_disabled())" test
> and the NAPI poll handler is called with irq disabled from
> netpoll_send_skb_on_dev.
> 

Indeed. Also there have been changes from Eric Biederman not long ago,
which did just the opposite: replace dev_kfree() with dev_kfree_any()
for that reason. See

http://marc.info/?l=linux-stable-commits&m=142965098111361&w=2

[CCing Eric]

Regards,
Lino
