From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: RE: [linuxwifi] [PATCH] net: wireless: intel: iwlwifi: dvm: fix tid
 mask
Date: Thu, 8 Jun 2017 08:31:02 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB3E55212B0@hasmsx107.ger.corp.intel.com>
References: <20170607223354.22399-1-kirkseraph@gmail.com>
 <0BA3FCBA62E2DC44AF3030971E174FB3E5520A41@hasmsx107.ger.corp.intel.com>
 <20170608074954.qihkavvqdtwn4zmp@macchiaveli>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "luca@coelho.fi" <luca@coelho.fi>,
        "Berg, Johannes" <johannes.berg@intel.com>,
        "Coelho, Luciano" <luciano.coelho@intel.com>,
        linuxwifi <linuxwifi@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "open list:INTEL WIRELESS WIFI LINK (iwlwifi)"
        <linux-wireless@vger.kernel.org>,
        "open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Seraphime Kirkovski <kirkseraph@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608074954.qihkavvqdtwn4zmp@macchiaveli>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> On Thu, Jun 08, 2017 at 06:31:01AM +0000, Grumbach, Emmanuel wrote:
> > Hi,
> 
> Hi,
> 
> > True, OTOH we need tid to be 8 sometimes. We *just* need to make sure
> > that we don't index tid_data with this. Hence I think the proper fix is:
> >
> > diff --git a/drivers/net/wireless/intel/iwlwifi/dvm/tx.c
> > b/drivers/net/wireless/intel/iwlwifi/dvm/tx.c
> > index 06ac3f1..16a8646 100644
> > --- a/drivers/net/wireless/intel/iwlwifi/dvm/tx.c
> > +++ b/drivers/net/wireless/intel/iwlwifi/dvm/tx.c
> > @@ -1190,11 +1190,11 @@ void iwlagn_rx_reply_tx(struct iwl_priv *priv,
> struct iwl_rx_cmd_buffer *rxb)
> >                                 next_reclaimed;
> >                         IWL_DEBUG_TX_REPLY(priv, "Next reclaimed packet:%d\n",
> >                                                   next_reclaimed);
> > +                       iwlagn_check_ratid_empty(priv, sta_id, tid);
> >                 }
> >
> >                 iwl_trans_reclaim(priv->trans, txq_id, ssn, &skbs);
> >
> > -               iwlagn_check_ratid_empty(priv, sta_id, tid);
> >                 freed = 0;
> >
> >                 /* process frames */
> 
> I can confirm it works. You can add my Tested-By.

Patch in review in our internal tree. It'll be upstreamed through the regular process.
Thanks for your report and debug work.
