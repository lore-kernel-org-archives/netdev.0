From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH] ath9k : Fix ieee80211 work while going to suspend
Date: Fri, 22 Mar 2013 08:08:47 -0700
Message-ID: <20130322150847.GH32416@pogo>
References: <CAOULuOb0_40EX+6A_HM8eJN7kj9J4WhO9UhZbUUqng1Sfy_SQg@mail.gmail.com>
 <20130318191340.GA28919@tuxdriver.com>
 <20130318210308.GD32416@pogo>
 <20130321114219.GB1459@redhat.com>
 <20130321193331.GB32416@pogo>
 <20130322091342.GB1496@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Parag Warudkar <parag.lkml@gmail.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	<linux-wireless@vger.kernel.org>, <ath9k-devel@venema.h4ckr.net>,
	<netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	<senthilb@qca.qualcomm.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130322091342.GB1496@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 22, 2013 at 10:13:42AM +0100, Stanislaw Gruszka wrote:
> On Thu, Mar 21, 2013 at 12:33:31PM -0700, Luis R. Rodriguez wrote:
> > OK how about this for stable for now:
> > 
> > diff --git a/drivers/net/wireless/ath/ath9k/link.c b/drivers/net/wireless/ath/ath9k/link.c
> > index 39c84ec..7fdac6c 100644
> > --- a/drivers/net/wireless/ath/ath9k/link.c
> > +++ b/drivers/net/wireless/ath/ath9k/link.c
> > @@ -170,7 +170,8 @@ void ath_rx_poll(unsigned long data)
> >  {
> >  	struct ath_softc *sc = (struct ath_softc *)data;
> >  
> > -	ieee80211_queue_work(sc->hw, &sc->hw_check_work);
> > +	if (!test_bit(SC_OP_INVALID, &sc->sc_flags))
> > +		ieee80211_queue_work(sc->hw, &sc->hw_check_work);
> >  }
> 
> That looks ok for me as -stable fix
> 
> Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>

Parag, can you test the above to ensure it fixes your issue ?

  Luis
