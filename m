From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] vxlan: fix rcu related warnings
Date: Tue, 30 Jul 2013 15:17:21 -0700
Message-ID: <CALnjE+qx1L5p6CzFcd4nMTvWbxm-7_bz10wjbuUJdt12Q4Kqpg@mail.gmail.com>
References: <20130730131844.7d3f92de@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Thomas Richter <tmricht@linux.vnet.ibm.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:34701 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753216Ab3G3WRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 18:17:23 -0400
Received: by mail-qc0-f177.google.com with SMTP id e11so3339737qcx.8
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 15:17:22 -0700 (PDT)
In-Reply-To: <20130730131844.7d3f92de@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 30, 2013 at 1:18 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> Vxlan remote list is protected by RCU but since first_remote
> returns a bare pointer, sparse complains.
> Split out the rcu and non-rcu access to the list.
>
> Ok to replace list_for_or_null with just list_entry_rcu because
> remotes list must be non-empty.
>
I am still getting following sparse waning.

  CHECK   drivers/net/vxlan.c
drivers/net/vxlan.c:181:16: warning: incorrect type in return
expression (different address spaces)
drivers/net/vxlan.c:181:16:    expected struct vxlan_rdst [noderef] <asn:4>*
drivers/net/vxlan.c:181:16:    got struct vxlan_rdst *<noident>
drivers/net/vxlan.c:748:59: warning: incorrect type in initializer
(different address spaces)
drivers/net/vxlan.c:748:59:    expected struct vxlan_rdst *rdst
drivers/net/vxlan.c:748:59:    got struct vxlan_rdst [noderef] <asn:4>*
drivers/net/vxlan.c:181:16: warning: incorrect type in return
expression (different address spaces)
drivers/net/vxlan.c:181:16:    expected struct vxlan_rdst [noderef] <asn:4>*
drivers/net/vxlan.c:181:16:    got struct vxlan_rdst *<noident>
drivers/net/vxlan.c:996:42: warning: dereference of noderef expression
