From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] natsemi: NAPI support
Date: Tue, 6 Dec 2005 22:56:19 +0100
Message-ID: <20051206215619.GB3425@electric-eye.fr.zoreil.com>
References: <20051204224734.GA12962@sirena.org.uk> <20051204231209.GA28949@electric-eye.fr.zoreil.com> <20051205232301.GA4551@sirena.org.uk> <20051206001934.GA18329@electric-eye.fr.zoreil.com> <20051206211729.GB3709@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Tim Hockin <thockin@hockin.org>,
	Harald Welte <laforge@gnumonks.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030276AbVLFWAk@vger.kernel.org>
To: Mark Brown <broonie@sirena.org.uk>
Content-Disposition: inline
In-Reply-To: <20051206211729.GB3709@sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Brown <broonie@sirena.org.uk> :
[...]
> Prior to waiting dev_close() clears __LINK_STATE_START which will cause
> netif_rx_schedule_prep() to return false.
> As far as I can see that should prevent the interrupt handler scheduling
> any further poll() calls?

netif_rx_schedule_prep return netif_running(dev) &&
dev_close              clear_bit(__LINK_STATE_START, &dev->state);
dev_close              smp_mb__after_clear_bit(); /* Commit netif_running(). */
dev_close              while (test_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
dev_close                      /* No hurry. */
dev_close                      msleep(1);
dev_close              }
dev_close              
netif_rx_schedule_prep !test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state);

--
Ueimor
