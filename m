From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next RFC 2/9] net: dsa: mv88e6xxx: expose switch time
 as a PTP hardware clock
Date: Sun, 8 Oct 2017 08:07:39 -0400
Message-ID: <20171008120737.32k3qf2omg5p2wgz@localhost>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-3-git-send-email-brandon.streiff@ni.com>
 <20170928170329.GC14940@lunn.ch>
 <CO2PR04MB218426561C8915B89947A79E9F7E0@CO2PR04MB2184.namprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Erik Hons <erik.hons@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CO2PR04MB218426561C8915B89947A79E9F7E0@CO2PR04MB2184.namprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 29, 2017 at 03:17:02PM +0000, Brandon Streiff wrote:
>  
> Although now that I'm looking it over again, I'm also not certain of
> the need. Even if we're called more frequently than we expect, that
> doesn't seem to be harmful with regard to timekeeping. Hmm.

Just keep it simple and drop the extra logic.  It doesn't hurt to
over-sample the clock.  Here is what I did:

/* Covers both a 100 or a 125 MHz input clock. */
#define MV88E635X_OVERFLOW_PERIOD (HZ * 16)

static void mv88e635x_overflow_check(struct work_struct *ws)
{
	struct timespec64 ts;
	struct mv88e6xxx_chip *ps =
		container_of(ws, struct mv88e6xxx_chip, oflow_work.work);

	mv88e635x_ptp_gettime(&ps->ptp_info, &ts);
	pr_debug("mv88e635x overflow check at %lld.%09lu\n",
		 ts.tv_sec, ts.tv_nsec);
	schedule_delayed_work(&ps->oflow_work, MV88E635X_OVERFLOW_PERIOD);
}

Thanks,
Richard
