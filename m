From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [net-next 07/10] igb: Added rcu_lock to avoid race
Date: Wed, 26 Jun 2013 12:52:41 -0700
Message-ID: <1372276361.3301.208.camel@edumazet-glaptop>
References: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1372244122-17664-8-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1372245628.3301.172.camel@edumazet-glaptop>
	 <CFEEE81102D91947B9CC368106979EBA4388266B@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Abodunrin, Akeem G" <akeem.g.abodunrin@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:39549 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963Ab3FZTw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 15:52:29 -0400
Received: by mail-ea0-f179.google.com with SMTP id b15so7867736eae.10
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 12:52:28 -0700 (PDT)
In-Reply-To: <CFEEE81102D91947B9CC368106979EBA4388266B@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-26 at 16:42 +0000, Abodunrin, Akeem G wrote:
> 
> > -----Original Message-----
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> > Sent: Wednesday, June 26, 2013 4:20 AM
> > To: Kirsher, Jeffrey T
> > Cc: davem@davemloft.net; Abodunrin, Akeem G; netdev@vger.kernel.org;
> > gospo@redhat.com; sassmann@redhat.com
> > Subject: Re: [net-next 07/10] igb: Added rcu_lock to avoid race
> > 
> > On Wed, 2013-06-26 at 03:55 -0700, Jeff Kirsher wrote:
> > > From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>
> > >
> > > This patch adds rcu_lock to avoid possible race condition with
> > > igb_update_stats function accessing the rings in free_ q_vector.
> > >
> > > Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
> > > Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > ---
> > >  drivers/net/ethernet/intel/igb/igb_main.c | 7 ++++++-
> > >  1 file changed, 6 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
> > > b/drivers/net/ethernet/intel/igb/igb_main.c
> > > index 7112e52..c74ad78 100644
> > > --- a/drivers/net/ethernet/intel/igb/igb_main.c
> > > +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> > > @@ -705,6 +705,8 @@ static void __exit igb_exit_module(void)
> > >  	dca_unregister_notify(&dca_notifier);
> > >  #endif
> > >  	pci_unregister_driver(&igb_driver);
> > > +
> > > +	rcu_barrier(); /* Wait for completion of call_rcu()'s */
> > >  }
> > >
> > 
> > This is not needed.
> > 
> > If this is really needed, a better comment would be welcomed ;)
> 
> Thanks Eric!
> 
> I believe we need this to make sure memory is released before removing
> driver code from the kernel, especially with each call to rcu - that
> is the reason for the comment "Wait for completion of call_rcu()'s".

You did not add call_rcu() in this patch, therefore you do not need
this.

I am extra careful of people adding useless rcu synchronization just
because they feel better :)
